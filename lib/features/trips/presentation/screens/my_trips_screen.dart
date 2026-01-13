
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/trips/presentation/widgets/trip_card.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';

// Provider to stream the list of trips from Firestore
final tripsStreamProvider = StreamProvider<List<Trip>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final stream = firestore.collection('trips').snapshots();

  return stream.map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        // Note: This is a basic mapping. You might need to handle nulls and defaults.
        return Trip()
          ..remoteId = doc.id
          ..name = data['name'] ?? 'Unnamed Trip'
          ..startDate = (data['startDate'] as Timestamp?)?.toDate()
          ..endDate = (data['endDate'] as Timestamp?)?.toDate();
      }).toList());
});

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsyncValue = ref.watch(tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: tripsAsyncValue.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text('No trips yet!'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              // Pass the actual trip data to the TripCard
              return TripCard(key: ValueKey(trip.remoteId));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
