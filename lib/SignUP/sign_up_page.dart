import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/SignUP/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:supabase_project/login/login_page.dart';
import 'package:supabase_project/textfield.dart'; // Import your LoginPage
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wc_form_validators/wc_form_validators.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _kwhRateController = TextEditingController();
  late final TextEditingController controller;
  bool _showClearIcon = false;
  bool _showClearEmailIcon = false;
  bool _showClearPasswordIcon = false;

  bool _isLoading = false; // Loading state
  String? validatePassword(String value) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (value.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(value)) {
        return 'Enter valid password';
      } else {
        return null;
      }
    }
  }

  User user = User('', '', '', 0);
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _kwhRateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Stack(
            children: [
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15.0),
                      const Image(
                        image: AssetImage('assets/login.png'),
                        width: 500.0,
                        height: 250.0,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Become a member!'),
                            const Text('Enter your credentials to continue'),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFD1D1D1),
                                    offset: Offset(0.0, 5.0),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _usernameController,
                                  onChanged: (value) {
                                    setState(() {
                                      _showClearIcon = value.isNotEmpty;
                                    });
                                    user.username = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter Username';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    fillColor: Colors.white70,
                                    filled: true,
                                    hintText: 'Username',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'ProductSans',
                                      fontSize: 12.0,
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.person_outlined),
                                    suffixIcon: _showClearIcon
                                        ? IconButton(
                                            onPressed: () {
                                              _usernameController.clear();
                                              setState(() {
                                                _showClearIcon = false;
                                              });
                                            },
                                            icon: const Icon(Icons.clear),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFD1D1D1),
                                    offset: Offset(0.0, 5.0),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ),
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _kwhRateController,
                                  onChanged: (value) {
                                    setState(() {
                                      _showClearIcon = value.isNotEmpty;
                                    });

                                    // Convert the value to double and assign it
                                    final kwhRate = double.tryParse(value);
                                    if (kwhRate != null) {
                                      user.kwhRate = kwhRate;
                                    } else {
                                      // Handle the case where the conversion fails if needed
                                      user.kwhRate = 0; // or some default value
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter Kwh Rate';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    fillColor: Colors.white70,
                                    filled: true,
                                    hintText: 'Kwh Rate',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'ProductSans',
                                      fontSize: 12.0,
                                    ),
                                    prefixIcon:
                                        const Icon(Icons.person_outlined),
                                    suffixIcon: _showClearIcon
                                        ? IconButton(
                                            onPressed: () {
                                              _kwhRateController.clear();
                                              setState(() {
                                                _showClearIcon = false;
                                              });
                                            },
                                            icon: const Icon(Icons.clear),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFD1D1D1),
                                    offset: Offset(0.0, 5.0),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ), //BoxShadow
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _emailController,
                                  onChanged: (value) {
                                    setState(() {
                                      _showClearEmailIcon = value.isNotEmpty;
                                    });
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
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    fillColor: Colors.white70,
                                    filled: true,
                                    hintText: 'Email',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'ProductSans',
                                      fontSize: 12.0,
                                    ),
                                    prefixIcon: const Icon(Icons.lock_rounded),
                                    suffixIcon: _showClearEmailIcon
                                        ? IconButton(
                                            onPressed: () {
                                              _emailController.clear();
                                              setState(() {
                                                _showClearEmailIcon = false;
                                              });
                                            },
                                            icon: const Icon(Icons.clear),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFD1D1D1),
                                    offset: Offset(0.0, 5.0),
                                    blurRadius: 5.0,
                                    spreadRadius: 2.0,
                                  ), //BoxShadow
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _passwordController,
                                  onChanged: (value) {
                                    setState(() {
                                      _showClearPasswordIcon = value.isNotEmpty;
                                    });
                                    user.password = value;
                                  },
                                  validator: Validators.compose([
                                    Validators.required('Password is required'),
                                    Validators.patternString(
                                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                                        'Invalid Password')
                                  ]),
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    fillColor: Colors.white70,
                                    filled: true,
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: 'ProductSans',
                                      fontSize: 12.0,
                                    ),
                                    prefixIcon: const Icon(Icons.lock_rounded),
                                    suffixIcon: _showClearPasswordIcon
                                        ? IconButton(
                                            onPressed: () {
                                              _passwordController.clear();
                                              setState(() {
                                                _showClearPasswordIcon = false;
                                              });
                                            },
                                            icon: const Icon(Icons.clear),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SignUpButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    AuthService(
                                      context: context,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      usernameController: _usernameController,
                                      kwhRateController: _kwhRateController,
                                    ).signUp();
                                  } else {
                                    _showSnackBar('dfd');
                                  }
                                },
                                text: 'Sign Up'),
                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Text(
                                    'or sign up with',
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'ProductSans',
                                        fontSize: 12.0),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                            image: AssetImage(
                                                'assets/google.png')),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                            image: AssetImage(
                                                'assets/facebook.png')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 15,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 30.0),
                    backgroundColor: const Color(0xFF75FFBA),
                    elevation: 5.0,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
