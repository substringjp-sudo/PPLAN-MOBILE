import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@riverpod
class LocationService extends _$LocationService {
  @override
  FutureOr<void> build() {}

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> requestBackgroundPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.always;
    }
    return true;
  }
}
