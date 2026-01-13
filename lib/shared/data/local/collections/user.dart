
import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? remoteId; // Firestore Document ID

  late String name;
  
  @Index(unique: true)
  late String username;

  String? profilePictureUrl;

  int tripsCount = 0;

  int followersCount = 0;

  int followingCount = 0;

}
