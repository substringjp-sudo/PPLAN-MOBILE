import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/timeline/application/timeline_controller.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';
import 'package:mobile/features/timeline/presentation/widgets/photo_zone_bar.dart';
import 'package:mobile/features/timeline/presentation/widgets/active_photo_preview.dart';
import 'package:mobile/features/timeline/presentation/widgets/time_ruler_painter.dart';
import 'package:mobile/features/timeline/presentation/widgets/transport_capsule.dart';
import 'package:mobile/features/timeline/presentation/widgets/event_block.dart';
import 'package:mobile/features/timeline/presentation/widgets/range_selector.dart';
import 'package:mobile/features/timeline/presentation/utils/timeline_utils.dart';
import 'package:mobile/features/scrapbook/presentation/screens/quick_post_screen.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TimelineScreen({super.key, required this.tripId});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();
  double _zoomLevel = 1.0; // 1.0 = 1 pixel per minute (base)

  // Range Selection State
  double? _selectionStartX;
  double? _selectionCurrentX;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initial Load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripIdInt = int.tryParse(widget.tripId);
      if (tripIdInt != null) {
        ref.read(timelineControllerProvider.notifier).loadTripData(tripIdInt);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // TODO: 3.2. Update center time for Zoom logic (optional state update)
  }

  void _handleTimelineDragStart(DragStartDetails details) {
    setState(() {
      _selectionStartX = details.localPosition.dx + _scrollController.offset;
      _selectionCurrentX = details.localPosition.dx + _scrollController.offset;
    });
  }

  void _handleTimelineDragUpdate(DragUpdateDetails details) {
    setState(() {
      _selectionCurrentX = details.localPosition.dx + _scrollController.offset;
    });
  }

  void _handleTimelineDragEnd(DragEndDetails details) {
    // Keep selection visible
  }

  void _createTimelineItemFromSelection(TimelineItemType type) {
    final timelineState = ref.read(timelineControllerProvider);
    if (timelineState.trip?.startDate == null) return;
    final timelineStartTime = timelineState.trip!.startDate!;

    if (_selectionStartX == null || _selectionCurrentX == null) return;

    final startX = _selectionStartX! < _selectionCurrentX!
        ? _selectionStartX!
        : _selectionCurrentX!;
    final endX = _selectionStartX! < _selectionCurrentX!
        ? _selectionCurrentX!
        : _selectionStartX!;

    final startTime = TimelineUtils.pixelToTime(
      startX,
      timelineStartTime,
      _zoomLevel,
    );
    final endTime = TimelineUtils.pixelToTime(
      endX,
      timelineStartTime,
      _zoomLevel,
    );

    final item = TimelineItem()
      ..type = type
      ..title = type == TimelineItemType.accommodation
          ? 'New Stay'
          : 'New Activity'
      ..startTime = startTime
      ..endTime = endTime
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..tripId = widget.tripId;

    ref.read(timelineControllerProvider.notifier).addTimelineItem(item);

    setState(() {
      _selectionStartX = null;
      _selectionCurrentX = null;
    });
  }

  void _handleTransportLaneTap(TapUpDetails details) {
    final timelineState = ref.read(timelineControllerProvider);
    if (timelineState.trip?.startDate == null) return;
    final timelineStartTime = timelineState.trip!.startDate!;

    final tapX = details.localPosition.dx + _scrollController.offset;
    final tapTime = TimelineUtils.pixelToTime(
      tapX,
      timelineStartTime,
      _zoomLevel,
    );

    final draft = ref
        .read(timelineControllerProvider.notifier)
        .generateAutoFillDraft(tapTime);

    if (draft != null) {
      draft.tripId = widget.tripId;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Auto-fill Draft created: ${draft.startTime?.hour}:${draft.startTime?.minute} - ${draft.endTime?.hour}:${draft.endTime?.minute}',
          ),
        ),
      );
      ref.read(timelineControllerProvider.notifier).addTimelineItem(draft);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create draft here (Overlap or Out of bounds)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineControllerProvider);

    if (timelineState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Timeline - Trip #${widget.tripId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (timelineState.trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Timeline - Trip #${widget.tripId}')),
        body: const Center(child: Text('Trip not found.')),
      );
    }

    if (timelineState.trip!.startDate == null ||
        timelineState.trip!.endDate == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Timeline - Trip #${widget.tripId}')),
        body: Center(
          child: Text(
              'This trip doesn\'t have a start or end date set. Please edit the trip to add dates.'),
        ),
      );
    }

    final timelineStartTime = timelineState.trip!.startDate!;
    final timelineEndTime = timelineState.trip!.endDate!;
    final photos = timelineState.photos;
    final items = timelineState.items;

    final events = items
        .where((item) =>
            item.type == TimelineItemType.activity ||
            item.type == TimelineItemType.accommodation ||
            item.type == TimelineItemType.note)
        .toList();

    final transports = items
        .where((item) =>
            item.type == TimelineItemType.transport ||
            item.type == TimelineItemType.flight ||
            item.type == TimelineItemType.transit)
        .toList();

    final totalDurationMinutes =
        timelineEndTime.difference(timelineStartTime).inMinutes;
    final totalWidth = totalDurationMinutes * _zoomLevel;

    final activePhoto = photos.isNotEmpty ? photos.first : null;

    return Scaffold(
      appBar: AppBar(title: Text('Timeline - ${timelineState.trip?.name ?? 'Trip'}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuickPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          ActivePhotoPreview(activePhoto: activePhoto),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: totalWidth,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onHorizontalDragStart: _handleTimelineDragStart,
                          onHorizontalDragUpdate: _handleTimelineDragUpdate,
                          onHorizontalDragEnd: _handleTimelineDragEnd,
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            height: 80,
                            child: Stack(
                              children: [
                                ...photos.map((photo) {
                                  final x = TimelineUtils.timeToPixel(
                                    photo.timestamp,
                                    timelineStartTime,
                                    _zoomLevel,
                                  );
                                  return Positioned(
                                    left: x,
                                    top: 10,
                                    child: PhotoZoneBar(
                                      photo: photo,
                                      isHighlighted: false,
                                    ),
                                  );
                                }),
                                if (_selectionStartX != null &&
                                    _selectionCurrentX != null)
                                  RangeSelector(
                                    left: _selectionStartX! < _selectionCurrentX!
                                        ? _selectionStartX!
                                        : _selectionCurrentX!,
                                    width: (_selectionCurrentX! - _selectionStartX!).abs(),
                                    onCreateStay: () =>
                                        _createTimelineItemFromSelection(
                                            TimelineItemType.accommodation),
                                    onCreateActivity: () =>
                                        _createTimelineItemFromSelection(
                                            TimelineItemType.activity),
                                    onCancel: () => setState(() {
                                      _selectionStartX = null;
                                      _selectionCurrentX = null;
                                    }),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: Size(totalWidth, 30),
                          painter: TimeRulerPainter(
                            startTime: timelineStartTime,
                            endTime: timelineEndTime,
                            pixelsPerMinute: _zoomLevel,
                          ),
                        ),
                        Container(
                          height: 80,
                          color: Colors.blue[50],
                          child: Stack(
                            children: events.map((event) {
                              if (event.startTime == null || event.endTime == null) {
                                return const SizedBox();
                              }
                              final startX = TimelineUtils.timeToPixel(
                                event.startTime!,
                                timelineStartTime,
                                _zoomLevel,
                              );
                              final endX = TimelineUtils.timeToPixel(
                                event.endTime!,
                                timelineStartTime,
                                _zoomLevel,
                              );
                              return Positioned(
                                left: startX,
                                top: 10,
                                child: EventBlock(
                                  title: event.title,
                                  width: endX - startX,
                                  onTap: () {
                                    debugPrint('Edit event: ${event.id}');
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        GestureDetector(
                          onTapUp: _handleTransportLaneTap,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 60,
                            color: Colors.green[50],
                            child: Stack(
                              children: transports.map((transport) {
                                if (transport.startTime == null ||
                                    transport.endTime == null) {
                                  return const SizedBox();
                                }
                                final startX = TimelineUtils.timeToPixel(
                                  transport.startTime!,
                                  timelineStartTime,
                                  _zoomLevel,
                                );
                                final endX = TimelineUtils.timeToPixel(
                                  transport.endTime!,
                                  timelineStartTime,
                                  _zoomLevel,
                                );
                                return Positioned(
                                  left: startX,
                                  top: 10,
                                  child: TransportCapsule(
                                    title: transport.title,
                                    icon: Icons.directions_car,
                                    width: endX - startX,
                                    onTap: () {
                                      debugPrint('Edit transport: ${transport.id}');
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 2,
                      height: double.infinity,
                      color: Colors.red.withOpacity(0.8),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 50,
                  bottom: 200,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _zoomLevel,
                      min: 0.5,
                      max: 5.0,
                      onChanged: (val) {
                        setState(() {
                          _zoomLevel = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: const Center(child: Text('Editor Area (Bottom Sheet)')),
          ),
        ],
      ),
    );
  }
}
