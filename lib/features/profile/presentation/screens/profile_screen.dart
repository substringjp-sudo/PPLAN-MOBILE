
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:mobile/shared/data/local/collections/user.dart';

// Mock Auth Provider - in a real app, this would provide the current user's ID from Firebase Auth
final authProvider = Provider<String>((ref) => 'mock_user_id'); // Replace with actual user ID

// Provider to get the current user's profile data
final userProfileProvider = StreamProvider<User>((ref) {
  final userId = ref.watch(authProvider);
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('users').doc(userId);

  return docRef.snapshots().map((snapshot) {
    final data = snapshot.data();
    if (data == null) {
      // Create a default user if one doesn't exist
      final defaultUser = User()
        ..remoteId = userId
        ..name = 'New User'
        ..username = 'newuser'
        ..profilePictureUrl = 'https://source.unsplash.com/random/200x200?profile,face'
        ..tripsCount = 0
        ..followersCount = 0
        ..followingCount = 0;
      docRef.set({
        'name': defaultUser.name,
        'username': defaultUser.username,
        'profilePictureUrl': defaultUser.profilePictureUrl,
        'tripsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
      });
      return defaultUser;
    }
    return User()
      ..remoteId = snapshot.id
      ..name = data['name'] ?? 'N/A'
      ..username = data['username'] ?? 'N/A'
      ..profilePictureUrl = data['profilePictureUrl']
      ..tripsCount = data['tripsCount'] ?? 0
      ..followersCount = data['followersCount'] ?? 0
      ..followingCount = data['followingCount'] ?? 0;
  });
});


// Provider for the user's trips (travelogs)
final userTripsProvider = StreamProvider<List<Trip>>((ref) {
  final userId = ref.watch(authProvider);
  final firestore = FirebaseFirestore.instance;
  final collectionRef = firestore.collection('trips').where('userId', isEqualTo: userId);

  return collectionRef.snapshots().map((snapshot) => 
    snapshot.docs.map((doc) {
        final data = doc.data();
        return Trip()
          ..remoteId = doc.id
          ..name = data['name'] ?? 'Unnamed Trip'
          ..coverImageUrl = data['coverImageUrl']; // Make sure your Trip model has this
      }).toList()
  );
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final userTrips = ref.watch(userTripsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: userProfile.when(data: (user) => Text(user.username), error: (e,s) => const Text('Profile'), loading: () => const Text('...')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [IconButton(onPressed: () {}, icon: const Icon(LucideIcons.settings))],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: userProfile.when(
              data: (user) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profilePictureUrl != null ? NetworkImage(user.profilePictureUrl!) : null,
                      child: user.profilePictureUrl == null ? const Icon(LucideIcons.user, size: 50) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: textTheme.headlineSmall?.copyWith(color: AppColors.text)),
                    const SizedBox(height: 8),
                    Text('@${user.username}', style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText)),
                    const SizedBox(height: 24),
                    _buildStatsRow(user),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Center(child: Text('Error loading profile')),
            ),
          ),
        ],
        body: userTrips.when(
          data: (trips) => _buildTravelogsGrid(trips),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const Center(child: Text('Error loading trips')),
        ),
      ),
    );
  }

  Widget _buildStatsRow(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: 'Trips', value: user.tripsCount.toString()),
        _StatItem(label: 'Followers', value: user.followersCount.toString()),
        _StatItem(label: 'Following', value: user.followingCount.toString()),
      ],
    );
  }

  Widget _buildTravelogsGrid(List<Trip> trips) {
    if (trips.isEmpty) {
      return const Center(child: Text("You haven't posted any travelogs yet.", style: TextStyle(color: AppColors.mutedText)));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            image: trip.coverImageUrl != null 
                ? DecorationImage(image: NetworkImage(trip.coverImageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: trip.coverImageUrl == null ? const Center(child: Icon(LucideIcons.imageOff, color: AppColors.mutedText)) : null,
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: textTheme.titleLarge?.copyWith(color: AppColors.text, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
      ],
    );
  }
}
