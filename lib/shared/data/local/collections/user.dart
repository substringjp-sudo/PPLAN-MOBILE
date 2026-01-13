
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String remoteId; // Firestore Document ID (which is the Firebase Auth UID)

  late String name;
  late String username;
  String? profilePictureUrl;

  // Stats
  int tripsCount = 0;
  int followersCount = 0;
  int followingCount = 0;
}
