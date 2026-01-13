import 'package:isar/isar.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';

class TripRepository {
  final Isar _isar;

  TripRepository(this._isar);

  Future<Trip?> getTrip(int tripId) async {
    return await _isar.trips.get(tripId);
  }

  // Add other trip-related methods here if needed
  // e.g., getAllTrips, upsertTrip, deleteTrip
}
