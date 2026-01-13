import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:mobile/shared/data/local/collections/sync_action.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Future<Isar> isarDatabase(IsarDatabaseRef ref) async {
  // ignore: avoid_print
  print('PPLAN: Fetching application documents directory...');
  final dir = await getApplicationDocumentsDirectory();
  // ignore: avoid_print
  print('PPLAN: Directory path: ${dir.path}');

  // ignore: avoid_print
  print('PPLAN: Opening Isar database...');
  try {
    final isar = await Isar.open([
      ScrapSchema,
      TripSchema,
      SyncActionSchema,
      TimelineItemSchema,
    ], directory: dir.path);
    // ignore: avoid_print
    print('PPLAN: Isar instance created.');
    return isar;
  } catch (e) {
    // ignore: avoid_print
    print('PPLAN: Isar.open failed: $e');
    rethrow;
  }
}
