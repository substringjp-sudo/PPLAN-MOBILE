import 'package:isar/isar.dart';

part 'timeline_item.g.dart';

enum TimelineItemType {
  activity,
  flight,
  accommodation,
  note,
  transit,
  transport,
}

@collection
class TimelineItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId;

  @Index()
  late String tripId; // Local Isar ID or Remote ID (decide based on sync strategy)

  // To handle offline trips, we might need a localTripId (int)
  @Index()
  int? localTripId;

  @enumerated
  late TimelineItemType type;

  late String title;

  @Index()
  String? date; // YYYY-MM-DD

  @Index()
  DateTime? startTime;
  @Index()
  DateTime? endTime;

  String? description;
  String? memo;

  // Location
  String? placeName;
  String? address;
  double? lat;
  double? lng;

  // Photos / Media
  List<String>? media; // Local file paths or remote URLs

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  @Index()
  bool isSynced = false;

  @Index()
  bool isDeletedLocally = false;

  // Metadata for specific types (Flight, Accommodation)
  String? metaDataJson;
}
