// import 'package:supabase_project/Service/supabase_client.dart';
//
// Future<void> createUser(String username, String email, String password) async {
//   final response = await supabase
//       .from('users') // Replace with your table name
//       .insert({
//     'username': username,
//     'email': email,
//     'password':
//         password, // Note: Storing raw passwords is not recommended; use proper hashing
//   }).execute();
//
//   if (response.error != null) {
//     print('Error creating user: ${response.error!.message}');
//   } else {
//     print('User created successfully');
//   }
// }
//
// Future<void> fetchUsers() async {
//   final response = await supabase
//       .from('users') // Replace with your table name
//       .select()
//       .execute();
//
//   if (response.error != null) {
//     print('Error fetching users: ${response.error!.message}');
//   } else {
//     final users = response.data as List<dynamic>;
//     print('Users: $users');
//   }
// }
//
// Future<void> updateUser(int id, String username) async {
//   final response = await supabase
//       .from('users') // Replace with your table name
//       .update({'username': username})
//       .eq('id', id) // Replace 'id' with your primary key field
//       .execute();
//
//   if (response.error != null) {
//     print('Error updating user: ${response.error!.message}');
//   } else {
//     print('User updated successfully');
//   }
// }
//
// Future<void> deleteUser(int id) async {
//   final response = await supabase
//       .from('users') // Replace with your table name
//       .delete()
//       .eq('id', id) // Replace 'id' with your primary key field
//       .execute();
//
//   if (response.error != null) {
//     print('Error deleting user: ${response.error!.message}');
//   } else {
//     print('User deleted successfully');
//   }
// }
