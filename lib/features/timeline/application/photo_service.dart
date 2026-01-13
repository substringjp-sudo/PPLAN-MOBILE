import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart' hide LatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/features/timeline/domain/models/photo_model.dart';

final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService();
});

class PhotoService {
  // 3.5. Local Data Ingestion & 3.1. Location-Aware Coloring
  Future<List<Photo>> fetchAndProcessPhotos(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // 1. Request Permission
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      // Handle permission denied
      return [];
    }

    // 2. Filter options
    final FilterOptionGroup filterOption = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: startDate, max: endDate),
      orders: [OrderOption(type: OrderOptionType.createDate, asc: true)],
    );

    // 3. Fetch Assets (All albums for simplicity, or specific if needed)
    // "Recent" usually contains all photos
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) return [];

    // Usually the first album is "Recent" or "All"
    final AssetPathEntity recentAlbum = albums.first;

    // Get all assets in range
    final int assetCount = await recentAlbum.assetCountAsync;
    final List<AssetEntity> assets = await recentAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );

    // 4. Convert to Photo models and Apply Logic
    List<Photo> photos = [];
    Photo? prevPhoto;
    double currentHue = 0.0; // Red start

    for (final asset in assets) {
      final DateTime timestamp = asset.createDateTime;
      final LatLng? gps = await _getLatLng(asset);

      // Basic Photo creation
      Photo photo = Photo(
        id: asset.id,
        filePath:
            '', // File path might need async retrieval, leaving empty for now or fetch later
        timestamp: timestamp,
        gps: gps,
        // thumbnail will be handled by UI widget using the ID
      );

      // 3.1. Location-Aware Coloring Logic
      if (prevPhoto != null && prevPhoto.gps != null && photo.gps != null) {
        final double distance = Geolocator.distanceBetween(
          prevPhoto.gps!.latitude,
          prevPhoto.gps!.longitude,
          photo.gps!.latitude,
          photo.gps!.longitude,
        );

        photo = photo.copyWith(distanceFromPrev: distance);

        if (distance <= 20) {
          // Same place: Keep color
          photo = photo.copyWith(hue: currentHue);
        } else if (distance < 1200) {
          // Moving: Gradual shift
          // distance / 20 hue increase
          currentHue = (currentHue + (distance / 20.0)) % 360.0;
          photo = photo.copyWith(hue: currentHue);
        } else {
          // New place: Sharp shift (+60)
          currentHue = (currentHue + 60.0) % 360.0;
          photo = photo.copyWith(hue: currentHue);
        }
      } else {
        // First photo or no GPS
        photo = photo.copyWith(hue: currentHue, distanceFromPrev: 0);
      }

      // Update file path if necessary (expensive operation, maybe skip for list view)
      final file = await asset.file;
      if (file != null) {
        photo = photo.copyWith(filePath: file.path);
      }

      photos.add(photo);
      prevPhoto = photo;
    }

    return photos;
  }

  Future<LatLng?> _getLatLng(AssetEntity asset) async {
    final lat = asset.latitude;
    final lng = asset.longitude;
    // Check if valid (0,0 is often default for no GPS)
    if (lat == 0.0 && lng == 0.0) return null;
    return LatLng(lat ?? 0.0, lng ?? 0.0);
  }
}
