import 'package:isar/isar.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';

class TripRepository {
  final Isar isar;

  TripRepository(this.isar);

  Future<List<Trip>> getAllTrips() async {
    return await isar.trips.where().sortByUpdatedAtDesc().findAll();
  }

  Future<Trip?> getTripById(Id id) async {
    return await isar.trips.get(id);
  }

  Future<int> upsertTrip(Trip trip) async {
    return await isar.writeTxn(() async {
      trip.updatedAt = DateTime.now();
      return await isar.trips.put(trip);
    });
  }

  Future<bool> deleteTripLocally(Id id) async {
    return await isar.writeTxn(() async {
      final trip = await isar.trips.get(id);
      if (trip == null) return false;

      trip.isDeletedLocally = true;
      trip.isSynced = false;
      trip.updatedAt = DateTime.now();
      await isar.trips.put(trip);
      return true;
    });
  }
}
