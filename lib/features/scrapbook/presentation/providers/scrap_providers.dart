import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/shared/data/local/repositories/scrap_repository.dart';

part 'scrap_providers.g.dart';

@riverpod
Stream<List<Scrap>> scrapList(ScrapListRef ref) {
  final repo = ref.watch(scrapRepositoryProvider);
  return repo.watchScraps();
}

@riverpod
class QuickPostController extends _$QuickPostController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> savePost({
    required String content,
    required ScrapType type,
    String? metaData,
    double? lat,
    double? lng,
    String? imagePath,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final scrap = Scrap()
        ..content = imagePath ?? content
        ..type = type
        ..metaData = metaData
        ..lat = lat
        ..lng = lng
        ..createdAt = DateTime.now()
        ..isSynced = false;

      await ref.read(scrapRepositoryProvider).saveScrap(scrap);
    });
  }
}
