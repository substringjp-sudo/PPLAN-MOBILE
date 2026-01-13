
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/data/local/collections/trip.dart'; // Assuming you have a Trip model

// Mock provider for liked trips - in a real app, this would fetch liked trips from a data source
final likedTripsProvider = Provider<List<Trip>>((ref) {
  // For now, return a list of mock trips
  return List.generate(5, (index) => Trip()
    ..remoteId = 'trip_$index'
    ..name = 'Dream Vacation $index'
    ..coverImageUrl = 'https://source.unsplash.com/random/400x300?travel,landscape,$index'
  );
});

class LikesScreen extends ConsumerWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedTrips = ref.watch(likedTripsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Liked Trips'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: likedTrips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.heartOff, size: 48, color: AppColors.mutedText),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t liked any trips yet.',
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: likedTrips.length,
              itemBuilder: (context, index) {
                final trip = likedTrips[index];
                return _buildLikedTripCard(context, trip);
              },
            ),
    );
  }

  Widget _buildLikedTripCard(BuildContext context, Trip trip) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: trip.coverImageUrl != null 
                    ? DecorationImage(image: NetworkImage(trip.coverImageUrl!), fit: BoxFit.cover)
                    : null,
                color: AppColors.background
              ),
              child: trip.coverImageUrl == null ? const Icon(LucideIcons.image, color: AppColors.mutedText) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                   Row(
                    children: const [
                      Icon(LucideIcons.user, size: 12, color: AppColors.mutedText),
                      SizedBox(width: 4),
                      Text('Author Name', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.heart, color: AppColors.secondary),
              onPressed: () { /* TODO: Implement unlike functionality */ },
            ),
          ],
        ),
      ),
    );
  }
}
