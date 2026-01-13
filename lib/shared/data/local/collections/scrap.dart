import 'package:isar/isar.dart';

part 'scrap.g.dart';

enum ScrapType { link, text, image, place }

@collection
class Scrap {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  @Index(type: IndexType.value)
  late String content; // The raw shared text/url

  @enumerated
  late ScrapType type;

  /// JSON string containing title, description, image etc.
  String? metaData;

  @Index()
  double? lat;

  @Index()
  double? lng;

  @Index()
  late DateTime createdAt;

  @Index()
  bool isSynced = false;

  @Index()
  bool isDeletedLocally = false;

  @Index()
  late DateTime updatedAt;
}
