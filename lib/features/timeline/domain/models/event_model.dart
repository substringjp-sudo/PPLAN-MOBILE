import 'package:google_maps_flutter/google_maps_flutter.dart';

enum EventType { sightseeing, meal, cafe, accommodation, visit, other }

class Event {
  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final EventType type;
  final String? location; // Place name
  final LatLng? locationCoordinates;
  final List<String> selectedPhotoIds;

  const Event({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.type,
    this.location,
    this.locationCoordinates,
    this.selectedPhotoIds = const [],
  });

  Event copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? title,
    EventType? type,
    String? location,
    LatLng? locationCoordinates,
    List<String>? selectedPhotoIds,
  }) {
    return Event(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
      type: type ?? this.type,
      location: location ?? this.location,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      selectedPhotoIds: selectedPhotoIds ?? this.selectedPhotoIds,
    );
  }
}
