
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/data/local/collections/activity.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Provider for the main trip details
final tripDetailProvider = StreamProvider.family<Trip, String>((ref, tripId) {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('trips').doc(tripId);
  return docRef.snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception('Trip not found!');
    return Trip()
      ..remoteId = snapshot.id
      ..name = data['name'] ?? 'Unnamed Trip';
  });
});

// Provider for the activities within a trip
final tripActivitiesProvider = StreamProvider.family<List<Activity>, String>((ref, tripId) {
  final firestore = FirebaseFirestore.instance;
  final collectionRef = firestore.collection('trips').doc(tripId).collection('activities').orderBy('time');
  return collectionRef.snapshots().map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Activity()
          ..remoteId = doc.id
          ..name = data['name'] ?? 'Unnamed Activity'
          ..time = data['time']
          ..category = data['category'];
      }).toList());
});

class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripDetailProvider(tripId));
    final activitiesAsync = ref.watch(tripActivitiesProvider(tripId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tripAsync.when(
        data: (trip) => CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(trip.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                background: Image.network('https://source.unsplash.com/random/800x600?travel,landscape', fit: BoxFit.cover),
              ),
            ),
            activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No activities planned yet."))));
                }
                // For now, we assume all activities are for one day.
                // Grouping by date would be the next step.
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) return const _DayHeader(day: 1);
                        final activity = activities[index -1];
                        return _TimelineActivityItem(
                          activity: activity,
                          isFirst: index == 1,
                          isLast: index == activities.length,
                        );
                      },
                      childCount: activities.length + 1,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error loading activities: $err'))),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final int day;
  const _DayHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
          child: Text('Day $day', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }
}

class _TimelineActivityItem extends StatelessWidget {
  final Activity activity;
  final bool isFirst;
  final bool isLast;

  const _TimelineActivityItem({required this.activity, this.isFirst = false, this.isLast = false});

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'camera': return LucideIcons.camera;
      case 'fork': return LucideIcons.utensils;
      case 'plane': return LucideIcons.plane;
      default: return LucideIcons.pencil;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.25,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(color: AppColors.mutedText, thickness: 2),
      indicatorStyle: const IndicatorStyle(
        width: 40,
        height: 40,
        indicator: CircleAvatar(backgroundColor: AppColors.surface, child: Icon(LucideIcons.check, color: AppColors.primary, size: 20)),
      ),
      endChild: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Icon(_getIconForCategory(activity.category), color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(activity.name, style: const TextStyle(color: AppColors.text, fontSize: 16))),
          ]),
        ),
      ),
      startChild: Center(child: Text(activity.time ?? '', style: const TextStyle(color: AppColors.mutedText, fontWeight: FontWeight.bold))),
    );
  }
}
