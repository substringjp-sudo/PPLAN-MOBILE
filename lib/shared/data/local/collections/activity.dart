
import 'package:isar/isar.dart';

part 'activity.g.dart';

enum ActivityCategory {
  transport,
  accommodation,
  food,
  attraction,
  other,
}

@collection
class Activity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId; // Firestore Document ID

  late String name;

  @enumerated
  late ActivityCategory category;

  late int day; // Relative day number in the trip

  late String startTime; // "HH:mm"

  @Index()
  String? tripId; // remoteId of the parent trip

  Activity();

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity()
      ..remoteId = json['id'] as String?
      ..name = json['name'] as String
      ..day = json['day'] as int
      ..startTime = json['startTime'] as String
      ..tripId = json['tripId'] as String?
      ..category = ActivityCategory.values.firstWhere(
        (e) => e.toString() == 'ActivityCategory.${json['category']}',
        orElse: () => ActivityCategory.other,
      );
  }
}
