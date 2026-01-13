import 'package:isar/isar.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';

class TripRepository {
  final Isar _isar;

  TripRepository(this._isar);

  Future<Trip?> getTrip(int tripId) async {
    return await _isar.trips.get(tripId);
  }

  Future<List<Trip>> getAllTrips() async {
    return await _isar.trips.where().findAll();
  }

  Future<void> upsertTrip(Trip trip) async {
    await _isar.writeTxn(() async {
      await _isar.trips.put(trip);
    });
  }

  // Add other trip-related methods here if needed
  // e.g., deleteTrip
}
