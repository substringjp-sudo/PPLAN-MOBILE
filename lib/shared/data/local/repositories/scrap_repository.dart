import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';
import 'package:mobile/shared/data/local/repositories/sync_repository.dart';
import 'package:mobile/shared/data/local/collections/sync_action.dart';

part 'scrap_repository.g.dart';

class ScrapRepository {
  final Isar isar;
  final SyncRepository _syncRepository;

  ScrapRepository(this.isar, this._syncRepository);

  Future<void> saveScrap(Scrap scrap) async {
    await isar.writeTxn(() async {
      await isar.scraps.put(scrap);
    });

    // Queue sync action
    await _syncRepository.pushAction(
      collectionName: 'scraps',
      documentId: scrap.id.toString(),
      operation: SyncOperation.create,
      payload: {
        'content': scrap.content,
        'type': scrap.type.name,
        'metaData': scrap.metaData,
        'createdAt': scrap.createdAt.toIso8601String(),
      },
    );
  }

  Stream<List<Scrap>> watchScraps() {
    return isar.scraps.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<void> markAsSynced(Id id) async {
    await isar.writeTxn(() async {
      final scrap = await isar.scraps.get(id);
      if (scrap != null) {
        scrap.isSynced = true;
        await isar.scraps.put(scrap);
      }
    });
  }

  Future<List<Scrap>> getUnsyncedScraps() async {
    return isar.scraps.filter().isSyncedEqualTo(false).findAll();
  }
}

@riverpod
ScrapRepository scrapRepository(ScrapRepositoryRef ref) {
  final isar = ref.watch(isarDatabaseProvider).requireValue;
  final syncRepository = ref.watch(syncRepositoryProvider);
  return ScrapRepository(isar, syncRepository);
}
