import 'package:google_maps_flutter/google_maps_flutter.dart';

class Photo {
  final String id;
  final String filePath;
  final DateTime timestamp;
  final LatLng? gps;
  final String? thumbnail; // Path to cached thumbnail or memory bytes key
  final String? locationLabel; // Google Maps based location name
  final double? hue; // Calculated color value (0-360)
  final double? distanceFromPrev; // Distance from previous photo in meters

  const Photo({
    required this.id,
    required this.filePath,
    required this.timestamp,
    this.gps,
    this.thumbnail,
    this.locationLabel,
    this.hue,
    this.distanceFromPrev,
  });

  Photo copyWith({
    String? id,
    String? filePath,
    DateTime? timestamp,
    LatLng? gps,
    String? thumbnail,
    String? locationLabel,
    double? hue,
    double? distanceFromPrev,
  }) {
    return Photo(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      timestamp: timestamp ?? this.timestamp,
      gps: gps ?? this.gps,
      thumbnail: thumbnail ?? this.thumbnail,
      locationLabel: locationLabel ?? this.locationLabel,
      hue: hue ?? this.hue,
      distanceFromPrev: distanceFromPrev ?? this.distanceFromPrev,
    );
  }
}
