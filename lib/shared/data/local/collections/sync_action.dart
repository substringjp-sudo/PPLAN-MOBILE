import 'package:isar/isar.dart';

part 'sync_action.g.dart';

enum SyncOperation { create, update, delete }

@collection
class SyncAction {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String actionId;

  late String collectionName;
  late String documentId;

  @enumerated
  late SyncOperation operation;

  late String payloadJson;

  @Index()
  late DateTime createdAt;

  int retryCount = 0;

  @Index()
  bool isCompleted = false;

  String? lastError;
}
