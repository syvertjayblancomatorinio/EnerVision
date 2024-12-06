import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserService {
  // Fetch the current user's userId from Hive
  static Future<String?> getUserId() async {
    try {
      final box = await Hive.openBox<User>('userBox');
      final currentUser = box.get('currentUser');
      return currentUser?.userId;
    } catch (e) {
      print('Error fetching user ID from Hive: $e');
      return null;
    }
  }

  // Fetch the full current user object
  static Future<User?> getCurrentUser() async {
    try {
      final box = await Hive.openBox<User>('userBox');
      final currentUser = box.get('currentUser');
      return currentUser;
    } catch (e) {
      print('Error fetching user from Hive: $e');
      return null;
    }
  }
}
