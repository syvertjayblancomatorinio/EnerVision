import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String profilePicture;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.profilePicture,
  });
  @override
  String toString() {
    return 'User{userId: $userId, username: $username, email: $email, profilePicture: $profilePicture}';
  }

}
