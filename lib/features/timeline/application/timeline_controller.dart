import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/timeline/domain/models/photo_model.dart';
import 'package:mobile/features/timeline/application/photo_service.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';
import 'package:mobile/shared/data/local/repositories/timeline_repository.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';

// State for Timeline Data
class TimelineState {
  final List<Photo> photos;
  final List<TimelineItem> items; // Items from Isar
  final bool isLoading;

  TimelineState({
    this.photos = const [],
    this.items = const [],
    this.isLoading = false,
  });

  TimelineState copyWith({
    List<Photo>? photos,
    List<TimelineItem>? items,
    bool? isLoading,
  }) {
    return TimelineState(
      photos: photos ?? this.photos,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TimelineController extends StateNotifier<TimelineState> {
  final PhotoService _photoService;
  final TimelineRepository _timelineRepository;

  TimelineController(this._photoService, this._timelineRepository)
    : super(TimelineState());

  Future<void> loadTripData(
    int localTripId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    state = state.copyWith(isLoading: true);
    try {
      final photos = await _photoService.fetchAndProcessPhotos(
        startDate,
        endDate,
      );
      final items = await _timelineRepository.getItemsByTrip(localTripId);
      state = state.copyWith(photos: photos, items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addTimelineItem(TimelineItem item) async {
    await _timelineRepository.upsertItem(item);
    state = state.copyWith(items: [...state.items, item]);
  }

  // 3.4. Auto-fill Logic
  TimelineItem? generateAutoFillDraft(DateTime clickTime) {
    // Logic to find gaps
    // Find closest Item end before clickTime
    DateTime startPoint = state.items
        .where((e) => e.endTime != null && e.endTime!.isBefore(clickTime))
        .map((e) => e.endTime!)
        .fold(
          DateTime(2000),
          (prev, curr) => curr.isAfter(prev) ? curr : prev,
        ); // Max

    // Find closest Item start after clickTime
    DateTime endPoint = state.items
        .where((e) => e.startTime != null && e.startTime!.isAfter(clickTime))
        .map((e) => e.startTime!)
        .fold(
          DateTime(2100),
          (prev, curr) => curr.isBefore(prev) ? curr : prev,
        ); // Min

    if (startPoint.year == 2000 && endPoint.year == 2100) return null;

    final start = startPoint.year == 2000
        ? clickTime.subtract(const Duration(hours: 1))
        : startPoint;
    final end = endPoint.year == 2100
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
      return TimelineController(photoService, TimelineRepository(isar));
    });
