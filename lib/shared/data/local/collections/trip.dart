import 'package:isar/isar.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId; // Firestore Document ID

  late String name;

  String? description;

  DateTime? startDate;

  DateTime? endDate;

  @Index()
  bool isSynced = false;

  @Index()
  bool isDeletedLocally = false;

  @Index()
  String status = 'planning';

  String? tripType;

  DateTime? updatedAt;
}
