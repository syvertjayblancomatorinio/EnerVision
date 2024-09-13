// import 'package:supabase_flutter/supabase_flutter.dart';
//
// Future<void> getUserDetails() async {
//   final user = Supabase.instance.client.auth.currentUser;
//   if (user != null) {
//     final response = await Supabase.instance.client
//         .from('profiles')
//         .select()
//         .eq('id', user.id)
//         .single()
//         .execute();
//
//     if (response.error == null) {
//       print('User details: ${response.data}');
//     } else {
//       print('Error fetching user details: ${response.error!.message}');
//     }
//   } else {
//     print('No user is currently signed in');
//   }
// }
//
// Future<void> fetchUserDetails(String email) async {
//   final response = await Supabase.instance.client
//       .from('public.profiles')
//       .select('*')
//       .eq('email', email)
//       .single()
//       .execute();
//
//   if (response.error != null) {
//     print('Error fetching user details: ${response.error!.message}');
//   } else {
//     final user = response.data;
//     print('User details: $user');
//   }
// }
//
// Future<String> getUsername() async {
//   final session = Supabase.instance.client.auth.currentSession;
//
//   final userId = session?.user?.id;
//   if (userId == null) {
//     return 'User not logged in';
//   }
//   final response = await Supabase.instance.client
//       .from('profiles')
//       .select('username')
//       .eq('id', userId) // Ensure userId type matches
//       .single()
//       .execute();
//
//   if (response.error != null) {
//     print('Error fetching user details: ${response.error!.message}');
//     return 'Error fetching username';
//   }
//
//   final data = response.data as Map<String, dynamic>;
//   return data['username'] ?? 'No username found';
// }
