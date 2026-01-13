import 'package:isar/isar.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';

class TimelineRepository {
  final Isar isar;

  TimelineRepository(this.isar);

  Future<List<TimelineItem>> getItemsByTrip(int localTripId) async {
    return await isar.timelineItems
        .filter()
        .localTripIdEqualTo(localTripId)
        .sortByStartTime()
        .findAll();
  }

  Future<int> upsertItem(TimelineItem item) async {
    return await isar.writeTxn(() async {
      item.updatedAt = DateTime.now();
      return await isar.timelineItems.put(item);
    });
  }

  Future<bool> deleteItem(int id) async {
    return await isar.writeTxn(() async {
      final item = await isar.timelineItems.get(id);
      if (item == null) return false;

      if (item.remoteId == null) {
        // Not synced yet, just delete
        return await isar.timelineItems.delete(id);
      } else {
        // Synced, mark as deleted locally
        item.isDeletedLocally = true;
        item.isSynced = false;
        item.updatedAt = DateTime.now();
        await isar.timelineItems.put(item);
        return true;
      }
    });
  }
}
