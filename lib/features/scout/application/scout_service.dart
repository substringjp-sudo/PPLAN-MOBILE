import 'package:geolocator/geolocator.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';
import 'package:mobile/shared/services/location_service.dart';
import 'package:mobile/shared/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:isar/isar.dart';

part 'scout_service.g.dart';

@Riverpod(keepAlive: true)
class ScoutService extends _$ScoutService {
  @override
  FutureOr<void> build() {}

  /// Core logic to check proximity of all scraps to the current location.
  /// This should be called from both foreground (Timer) and background (Workmanager).
  Future<void> checkProximity() async {
    final locationService = ref.read(locationServiceProvider.notifier);
    final pos = await locationService.getCurrentPosition();
    if (pos == null) return;

    final isar = ref.read(isarDatabaseProvider).requireValue;

    // Fetch all scraps with location data
    // In a real app with many items, we'd use Isar filters for lat/lng range (bounding box)
    final scraps = await isar.scraps
        .filter()
        .latIsNotNull()
        .and()
        .lngIsNotNull()
        .findAll();

    for (final scrap in scraps) {
      final distance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        scrap.lat!,
        scrap.lng!,
      );

      // Notification threshold: 500 meters
      if (distance < 500) {
        await _notifyNearbyScrap(scrap, distance);
      }
    }
  }

  Future<void> _notifyNearbyScrap(Scrap scrap, double distance) async {
    final notificationService = ref.read(notificationServiceProvider.notifier);

    // Avoid double notifications for the same item in a short period
    // (Could use a timestamp check or a "lastNotified" field in Isar)

    await notificationService.showNotification(
      id: scrap.id,
      title: '📍 Nearby Scrapped Location!',
      body:
          'You are within ${distance.toStringAsFixed(0)}m of "${scrap.content}"',
      payload: scrap.id.toString(),
    );
  }
}
