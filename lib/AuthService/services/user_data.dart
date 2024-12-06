import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

Future<void> saveUserData(User user) async {
  final box = Hive.box<User>('userBox');

  // Save the user object to the box
  await box.put('currentUser', user);
}

Future<User?> getUserData() async {
  final box = Hive.box<User>('userBox');
  return box.get('currentUser');
}

// Future<void> saveToken(String token) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('token', token);
// }

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<String?> getUserId() async {
  var box = await Hive.openBox('userData');
  return box.get('userId');
}

Future<String?> getUserToken() async {
  var box = await Hive.openBox('userData');
  return box.get('token');
}

Future<void> storeUserToken(String token) async {
  var box = await Hive.openBox('userData');
  await box.put('token', token);
}

// Future<String?> getToken() async {
//   var box = await Hive.openBox('userData');
//   return box.get('token');
// }
Future<void> deleteUserData() async {
  // Open both boxes
  final userBox = await Hive.openBox<User>('userBox');
  final userDataBox = await Hive.openBox('userData');

  // Clear all data from both boxes
  await userBox.clear();
  await userDataBox.clear();
}
