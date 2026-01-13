import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/timeline/domain/models/photo_model.dart';
import 'package:mobile/features/timeline/application/photo_service.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:mobile/shared/data/local/repositories/timeline_repository.dart';
import 'package:mobile/shared/data/local/repositories/trip_repository.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';

// State for Timeline Data
class TimelineState {
  final Trip? trip;
  final List<Photo> photos;
  final List<TimelineItem> items; // Items from Isar
  final bool isLoading;

  TimelineState({
    this.trip,
    this.photos = const [],
    this.items = const [],
    this.isLoading = false,
  });

  TimelineState copyWith({
    Trip? trip,
    List<Photo>? photos,
    List<TimelineItem>? items,
    bool? isLoading,
  }) {
    return TimelineState(
      trip: trip ?? this.trip,
      photos: photos ?? this.photos,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TimelineController extends StateNotifier<TimelineState> {
  final PhotoService _photoService;
  final TimelineRepository _timelineRepository;
  final TripRepository _tripRepository;

  TimelineController(this._photoService, this._timelineRepository, this._tripRepository)
      : super(TimelineState());

  Future<void> loadTripData(int localTripId) async {
    state = state.copyWith(isLoading: true);
    try {
      final trip = await _tripRepository.getTrip(localTripId);
      if (trip == null) {
        // Handle case where trip is not found
        state = state.copyWith(isLoading: false);
        return;
      }

      if (trip.startDate == null || trip.endDate == null) {
        // Handle case where trip has no dates
        state = state.copyWith(isLoading: false, trip: trip);
        return;
      }

      final photos = await _photoService.fetchAndProcessPhotos(
        trip.startDate!,
        trip.endDate!,
      );
      final items = await _timelineRepository.getItemsByTrip(localTripId);

      state = state.copyWith(
        trip: trip,
        photos: photos,
        items: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Optionally, handle error state
    }
  }

  Future<void> addTimelineItem(TimelineItem item) async {
    await _timelineRepository.upsertItem(item);
    state = state.copyWith(items: [...state.items, item]);
  }

  TimelineItem? generateAutoFillDraft(DateTime clickTime) {
    DateTime startPoint = state.items
        .where((e) => e.endTime != null && e.endTime!.isBefore(clickTime))
        .map((e) => e.endTime!)
        .fold(
          state.trip?.startDate ?? DateTime(2000),
          (prev, curr) => curr.isAfter(prev) ? curr : prev,
        );

    DateTime endPoint = state.items
        .where((e) => e.startTime != null && e.startTime!.isAfter(clickTime))
        .map((e) => e.startTime!)
        .fold(
          state.trip?.endDate ?? DateTime(2100),
          (prev, curr) => curr.isBefore(prev) ? curr : prev,
        );

    if (startPoint.year == 2000 && endPoint.year == 2100) return null;

    final start = startPoint.isAtSameMomentAs(state.trip?.startDate ?? DateTime(2000))
        ? clickTime.subtract(const Duration(hours: 1))
        : startPoint;
    final end = endPoint.isAtSameMomentAs(state.trip?.endDate ?? DateTime(2100))
        ? clickTime.add(const Duration(hours: 1))
        : endPoint;

    return TimelineItem()
      ..type = TimelineItemType.activity
      ..title = 'New Activity'
      ..startTime = start
      ..endTime = end
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }
}

final timelineControllerProvider =
    StateNotifierProvider<TimelineController, TimelineState>((ref) {
      final photoService = ref.watch(photoServiceProvider);
      final isar = ref.watch(isarDatabaseProvider).value;
      if (isar == null) throw Exception('Database not ready');
      return TimelineController(
        photoService,
        TimelineRepository(isar),
        TripRepository(isar), // Provide TripRepository
      );
    });
