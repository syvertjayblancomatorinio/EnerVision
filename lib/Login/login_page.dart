import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/my_energy_diary_page.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/appliance_container.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/appliance_page.dart';
import 'package:supabase_project/Login/setup_profile.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:supabase_project/zNotUsedFiles/landing_page.dart';
import 'package:supabase_project/textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../SignUP/user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  User user = User('', '', '', 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Image(
                  image: AssetImage('assets/login.png'),
                  width: 500.0,
                  height: 250.0,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Enter your email and password',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.email_outlined,
                  onChanged: (value) {
                    user.email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Email';
                    } else if (RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return null;
                    } else {
                      return 'Enter Valid Email';
                    }
                  },
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _passwordController,
                  obscureText: true,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_open_outlined,
                  onChanged: (value) {
                    user.password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Password';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.toggle_off_outlined,
                        color: Colors.greenAccent,
                        size: 25.0,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Remember Me',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'ProductSans',
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'ProductSans',
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SignUpButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      AuthService(
                        context: context,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ).signIn();
                    } else {
                      _showSnackBar('Password incorrect');
                      print('not okay');
                    }
                  },
                  text: 'Sign In',
                ),
                const SizedBox(height: 25),
                const Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
                const Text(
                  'or login with',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'ProductSans',
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey[200],
                        ),
                        height: 50.0,
                        width: 150.0,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(image: AssetImage('assets/google.png')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey[200],
                        ),
                        height: 50.0,
                        width: 150.0,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(image: AssetImage('assets/facebook.png')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // ElevatedButton(
                //   onPressed: () {}, // Corrected to call _login
                //   child: const Text('Login'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
