import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/AuthService/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/textfield.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:supabase_project/CommonWidgets/textfield.dart'; // Import your LoginPage
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<void> _showErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Registration Error',
      message:
          "The email is already registered.\nPlease use a different email.",
      buttonText: 'OK',
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
                            CustomTextField(
                              controller: _usernameController,
                              hintText: 'Username',
                              obscureText: false,
                              prefixIcon: const Icon(Icons.person_outlined),
                              onChanged: (value) {
                                setState(() {
                                  user.username = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Username';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              controller: _kwhRateController,
                              hintText: 'Kwh Rate',
                              obscureText: false,
                              prefixIcon: const Icon(
                                  Icons.energy_savings_leaf_outlined),
                              onChanged: (value) {
                                setState(() {
                                  _showClearIcon = value.isNotEmpty;
                                });

                                final kwhRate = double.tryParse(value);
                                if (kwhRate != null) {
                                  user.kwhRate = kwhRate;
                                } else {
                                  user.kwhRate = 0;
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Kwh Rate';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              prefixIcon: const Icon(Icons.email_outlined),
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
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              keyboardType: TextInputType.text,
                              prefixIcon: const Icon(Icons.lock_outline),
                              obscureText: true, // text obscured
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
                            ),
                            const SizedBox(height: 20),
                            SignUpButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final response = await AuthService(
                                      context: context,
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      usernameController: _usernameController,
                                      kwhRateController: _kwhRateController,
                                    ).signUp();

                                    if (response != null) {
                                      if (response.statusCode == 400) {
                                        await _showErrorDialog(context);
                                      } else if (response.statusCode == 201) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()),
                                        );
                                      }
                                    } else {
                                      SnackBarHelper.showSnackBar(
                                          context, 'Internal Server Error');
                                    }
                                  } catch (e) {
                                    SnackBarHelper.showSnackBar(
                                        context, 'An error occurred');
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                } else {
                                  SnackBarHelper.showSnackBar(
                                      context, 'Please fill in all fields.');
                                }
                              },
                              text: 'Sign Up',
                            ),

                            // SignUpButton(
                            //     onPressed: () {
                            //       if (_formKey.currentState?.validate() ??
                            //           false) {
                            //         AuthService(
                            //           context: context,
                            //           emailController: _emailController,
                            //           passwordController: _passwordController,
                            //           usernameController: _usernameController,
                            //           kwhRateController: _kwhRateController,
                            //         ).signUp();
                            //       } else if (_formKey.currentState
                            //               ?.validate() ??
                            //           true) {
                            //         Fluttertoast.showToast(
                            //             msg: "Email is not available",
                            //             toastLength: Toast.LENGTH_SHORT,
                            //             gravity: ToastGravity.BOTTOM,
                            //             timeInSecForIosWeb: 1,
                            //             backgroundColor: Colors.red,
                            //             textColor: Colors.white,
                            //             fontSize: 16.0);
                            //       } else {
                            //         Fluttertoast.showToast(
                            //             msg: "Email is not available",
                            //             toastLength: Toast.LENGTH_SHORT,
                            //             gravity: ToastGravity.BOTTOM,
                            //             timeInSecForIosWeb: 1,
                            //             backgroundColor: Colors.red,
                            //             textColor: Colors.white,
                            //             fontSize: 16.0);
                            //       }
                            //     },
                            //     text: 'Sign Up'),
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
