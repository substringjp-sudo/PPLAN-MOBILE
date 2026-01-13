import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:mobile/shared/data/local/repositories/trip_repository.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';
import 'package:uuid/uuid.dart';

class TripState {
  final List<Trip> trips;
  final bool isLoading;

  TripState({this.trips = const [], this.isLoading = false});

  TripState copyWith({List<Trip>? trips, bool? isLoading}) {
    return TripState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TripController extends StateNotifier<TripState> {
  final TripRepository _repository;

  TripController(this._repository) : super(TripState()) {
    loadTrips();
  }

  Future<void> loadTrips() async {
    state = state.copyWith(isLoading: true);
    final trips = await _repository.getAllTrips();
    state = state.copyWith(trips: trips, isLoading: false);
  }

  Future<void> createTrip({
    required String name,
    required String tripType,
  }) async {
    final trip = Trip()
      ..remoteId = const Uuid()
          .v4() // Temporary remoteId until synced
      ..name = name
      ..tripType = tripType
      ..status = 'planning'
      ..updatedAt = DateTime.now();

    await _repository.upsertTrip(trip);
    await loadTrips();
  }
}

final tripControllerProvider = StateNotifierProvider<TripController, TripState>(
  (ref) {
    final isar = ref.watch(isarDatabaseProvider).value;
    if (isar == null) throw Exception('Database not ready');
    return TripController(TripRepository(isar));
  },
);
