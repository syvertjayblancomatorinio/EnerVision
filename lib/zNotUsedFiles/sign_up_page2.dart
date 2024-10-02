// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_project/ConstantTexts/Theme.dart';
// import 'package:supabase_project/SignUP/user.dart';
// import 'package:supabase_project/buttons/sign_up_button.dart';
// import 'package:supabase_project/login/login_page.dart';
// import 'package:supabase_project/textfield.dart'; // Import your LoginPage
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'package:wc_form_validators/wc_form_validators.dart';
//
// class SignUpPage2 extends StatefulWidget {
//   @override
//   _SignUpPage2State createState() => _SignUpPage2State();
// }
//
// class _SignUpPage2State extends State<SignUpPage2> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _usernameController = TextEditingController();
//   late final TextEditingController controller;
//   bool _showClearIcon = false;
//   bool _showClearEmailIcon = false;
//   bool _showClearPasswordIcon = false;
//
//   bool _isLoading = false; // Loading state
//
//   Future<void> save() async {
//     final url = Uri.parse("http://10.0.2.2:8080/signup");
//
//     var response = await http.post(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'email': _emailController.text,
//         'password': _passwordController.text,
//         'username': _usernameController.text
//       }),
//     );
//
//     print(response.body);
//     Navigator.push(
//         context, MaterialPageRoute(builder: (context) => LoginPage()));
//   }
//
//   User user = User('', '', '', 0);
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: AppTheme.getAppTheme(),
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Colors.grey[300],
//         body: SafeArea(
//           child: Stack(
//             children: [
//               if (_isLoading)
//                 const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 15.0),
//                       const Image(
//                         image: AssetImage('assets/login.png'),
//                         width: 500.0,
//                         height: 250.0,
//                       ),
//                       const SizedBox(height: 20),
//                       Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Become a member!'),
//                             const Text('Enter your credentials to continue'),
//                             const SizedBox(height: 20),
//                             _textFieldContainer(
//                               controller: _usernameController,
//                               hintText: 'Username',
//                               prefixIcon: Icons.person_outlined,
//                               onClear: () {
//                                 _usernameController.clear();
//                                 setState(() {
//                                   _showClearIcon = false;
//                                 });
//                               },
//                               showClearIcon: _showClearIcon,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _showClearIcon = value.isNotEmpty;
//                                 });
//                                 user.username = value;
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Enter Username';
//                                 } else {
//                                   return null;
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             _textFieldContainer(
//                               controller: _emailController,
//                               hintText: 'Email',
//                               prefixIcon: Icons.lock_rounded,
//                               onClear: () {
//                                 _emailController.clear();
//                                 setState(() {
//                                   _showClearEmailIcon = false;
//                                 });
//                               },
//                               showClearIcon: _showClearEmailIcon,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _showClearEmailIcon = value.isNotEmpty;
//                                 });
//                                 user.email = value;
//                               },
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Enter Email';
//                                 } else if (RegExp(
//                                         r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
//                                     .hasMatch(value)) {
//                                   return null;
//                                 } else {
//                                   return 'Enter Valid Email';
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             _textFieldContainer(
//                               controller: _passwordController,
//                               hintText: 'Password',
//                               prefixIcon: Icons.lock_rounded,
//                               onClear: () {
//                                 _passwordController.clear();
//                                 setState(() {
//                                   _showClearPasswordIcon = false;
//                                 });
//                               },
//                               showClearIcon: _showClearPasswordIcon,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _showClearPasswordIcon = value.isNotEmpty;
//                                 });
//                                 user.password = value;
//                               },
//                               validator: Validators.compose([
//                                 Validators.required('Password is required'),
//                                 Validators.patternString(
//                                     r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
//                                     'Invalid Password')
//                               ]),
//                             ),
//                             const SizedBox(height: 20),
//                             SignUpButton(
//                                 onPressed: () {
//                                   if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     save();
//                                   } else {
//                                     print('Form Invalid');
//                                   }
//                                 },
//                                 text: 'Sign Up'),
//                             const SizedBox(height: 25),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Divider(
//                                     thickness: 0.5,
//                                     color: Colors.grey[400],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 10.0),
//                                   child: Text(
//                                     'or sign up with',
//                                     style: TextStyle(
//                                         color: Colors.grey[700],
//                                         fontFamily: 'ProductSans',
//                                         fontSize: 12.0),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Divider(
//                                     thickness: 0.5,
//                                     color: Colors.grey[400],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 25),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: Container(
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: Colors.white),
//                                       borderRadius: BorderRadius.circular(30),
//                                       color: Colors.grey[200],
//                                     ),
//                                     height: 50.0,
//                                     width: 150.0,
//                                     child: const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Image(
//                                             image: AssetImage(
//                                                 'assets/google.png')),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 GestureDetector(
//                                   onTap: () {},
//                                   child: Container(
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(color: Colors.white),
//                                       borderRadius: BorderRadius.circular(30),
//                                       color: Colors.grey[200],
//                                     ),
//                                     height: 50.0,
//                                     width: 150.0,
//                                     child: const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Image(
//                                             image: AssetImage(
//                                                 'assets/facebook.png')),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 10,
//                 right: 15,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 5.0, horizontal: 30.0),
//                     backgroundColor: const Color(0xFF75FFBA),
//                     elevation: 5.0,
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 12.0,
//                       fontFamily: 'ProductSans',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Widget _textFieldContainer({
//   required TextEditingController controller,
//   required String hintText,
//   required IconData prefixIcon,
//   required void Function() onClear,
//   required bool showClearIcon,
//   required void Function(String) onChanged,
//   required String? Function(String?) validator,
//   bool obscureText = false,
// }) {
//   return Container(
//     margin: const EdgeInsets.symmetric(vertical: 8.0),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: const [
//         BoxShadow(
//           color: Color(0xFFD1D1D1),
//           offset: Offset(0.0, 5.0),
//           blurRadius: 5.0,
//           spreadRadius: 2.0,
//         ),
//       ],
//     ),
//     child: TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       onChanged: onChanged,
//       validator: validator,
//       decoration: InputDecoration(
//         hintText: hintText,
//         prefixIcon: Icon(prefixIcon, color: Colors.grey),
//         suffixIcon: showClearIcon
//             ? IconButton(
//                 icon: Icon(Icons.clear, color: Colors.grey),
//                 onPressed: onClear,
//               )
//             : null,
//         border: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
//       ),
//     ),
//   );
// }
