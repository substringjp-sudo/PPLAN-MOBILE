
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/data/local/collections/activity.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Provider to fetch a single trip with its activities
final tripDetailProvider = FutureProvider.family<Trip, String>((ref, tripId) async {
  final firestore = FirebaseFirestore.instance;
  final tripDoc = await firestore.collection('trips').doc(tripId).get();

  if (!tripDoc.exists) {
    throw Exception('Trip not found');
  }

  final tripData = tripDoc.data()!;
  tripData['id'] = tripDoc.id;

  // Fetch activities from the subcollection
  final activitiesSnapshot = await firestore.collection('trips').doc(tripId).collection('activities').get();
  final activities = activitiesSnapshot.docs.map((doc) {
    final activityData = doc.data();
    activityData['id'] = doc.id;
    return Activity.fromJson(activityData);
  }).toList();

  final trip = Trip.fromJson(tripData);
  trip.activities = activities; // Manually assign the fetched activities

  return trip;
});

class TripDetailScreen extends ConsumerWidget {
  final String? tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tripId == null) {
      return const Scaffold(body: Center(child: Text('Trip ID is missing.')));
    }

    final tripAsyncValue = ref.watch(tripDetailProvider(tripId!));

    return tripAsyncValue.when(
      data: (trip) => _TripDetailView(trip: trip), // We pass the loaded trip to the actual UI widget
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

// This widget contains the actual UI, once the trip data is successfully loaded.
class _TripDetailView extends StatelessWidget {
  final Trip trip;

  const _TripDetailView({required this.trip});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activitiesByDay = _groupActivitiesByDay(trip.activities);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(trip, textTheme),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (activitiesByDay.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text('No activities yet.', style: TextStyle(color: AppColors.mutedText))));
                }
                final day = activitiesByDay.keys.elementAt(index);
                final activities = activitiesByDay[day]!;
                return _buildDayTimeline(context, day, activities, textTheme);
              },
              childCount: activitiesByDay.isEmpty ? 1 : activitiesByDay.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Trip trip, TextTheme textTheme) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          trip.name,
          style: textTheme.titleLarge?.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        background: trip.coverImageUrl != null
            ? Image.network(
                trip.coverImageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.4),
                colorBlendMode: BlendMode.darken,
              )
            : Container(color: AppColors.primary.withOpacity(0.5)),
      ),
    );
  }

  Map<int, List<Activity>> _groupActivitiesByDay(List<Activity> activities) {
    final map = <int, List<Activity>>{};
    for (var activity in activities) {
      if (!map.containsKey(activity.day)) {
        map[activity.day] = [];
      }
      map[activity.day]!.add(activity);
    }
    map.forEach((day, activityList) {
      activityList.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    return map;
  }

  Widget _buildDayTimeline(BuildContext context, int day, List<Activity> activities, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayHeader(day, textTheme),
          const SizedBox(height: 24),
          ...activities.map((activity) => _buildActivityTile(context, activity, textTheme, activities.indexOf(activity) == activities.length - 1)),
        ],
      ),
    );
  }

   Widget _buildDayHeader(int day, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Day $day',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textWhite),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, Activity activity, TextTheme textTheme, bool isLast) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25,
      isLast: isLast,
      beforeLineStyle: const LineStyle(color: AppColors.mutedText, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        indicator: _buildActivityIcon(activity.category),
        padding: const EdgeInsets.all(4),
      ),
      endChild: _buildActivityCard(context, activity, textTheme),
    );
  }

  Widget _buildActivityIcon(ActivityCategory category) {
    IconData icon;
    switch (category) {
      case ActivityCategory.transport:
        icon = LucideIcons.plane;
        break;
      case ActivityCategory.accommodation:
        icon = LucideIcons.bed;
        break;
      case ActivityCategory.food:
        icon = LucideIcons.utensils;
        break;
      case ActivityCategory.attraction:
        icon = LucideIcons.camera;
        break;
      default:
        icon = LucideIcons.activity;
    }
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Center(child: Icon(icon, size: 20, color: AppColors.primary)),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(activity.name, style: textTheme.bodyLarge?.copyWith(color: AppColors.textWhite))),
            const SizedBox(width: 8),
            Text(
              activity.startTime,
              style: textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
