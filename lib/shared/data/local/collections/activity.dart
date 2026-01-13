
import 'package:isar/isar.dart';

part 'activity.g.dart';

@collection
class Activity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId; // Firestore Document ID

  late String name;

  String? time; // e.g., "09:00"

  String? category; // e.g., "camera", "fork", "plane"

  DateTime? date; // To group by day

  @Index()
  late String tripId;
}
