
import 'package:isar/isar.dart';
import 'package:mobile/shared/data/local/collections/activity.dart';

part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId; // Firestore Document ID

  late String name;

  String? description;

  DateTime? startDate;

  DateTime? endDate;

  String? coverImageUrl;

  @Index()
  String? userId;

  @Index()
  bool isSynced = false;

  @Index()
  bool isDeletedLocally = false;

  @Index()
  String status = 'planning';

  String? tripType;

  DateTime? updatedAt;

  @ignore
  List<Activity> activities = [];

  Trip();

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip()
      ..remoteId = json['id'] as String?
      ..name = json['name'] as String
      ..description = json['description'] as String?
      ..startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null
      ..endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null
      ..coverImageUrl = json['coverImageUrl'] as String?
      ..userId = json['userId'] as String?
      ..status = json['status'] as String? ?? 'planning'
      ..tripType = json['tripType'] as String?
      ..updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null
      ..activities = (json['activities'] as List<dynamic>? ?? [])
          .map((activityJson) => Activity.fromJson(activityJson as Map<String, dynamic>))
          .toList();
  }
}
