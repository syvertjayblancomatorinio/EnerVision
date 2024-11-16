import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/AuthService/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/loading_page.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/setup_profile.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/textfield.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/buttons/login_signUp.dart';

import 'package:wc_form_validators/wc_form_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final AppControllers controllers = AppControllers();

  bool _showClearIcon = false;
  bool _showClearEmailIcon = false;
  bool _showClearPasswordIcon = false;
  bool _isLoading = false;

  User user = User('', '', '');
  @override
  void dispose() {
    controllers.usernameController.dispose();
    controllers.emailController.dispose();
    controllers.passwordController.dispose();
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
        body: SafeArea(
          child: Stack(
            children: [
              if (_isLoading)
                const Center(
                  child: LoadingWidget(
                    message: 'Logging in...',
                    color: AppColors.primaryColor,
                  ),
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
                        height: 300.0,
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Become a member!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Enter your credentials to continue',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: controllers.usernameController,
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
                              controller: controllers.emailController,
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
                              controller: controllers.passwordController,
                              hintText: 'Password',
                              keyboardType: TextInputType.text,
                              prefixIcon: const Icon(Icons.lock_outline),
                              obscureText: true,
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
                            const SizedBox(height: 50),
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
                                      emailController:
                                          controllers.emailController,
                                      passwordController:
                                          controllers.passwordController,
                                      usernameController:
                                          controllers.usernameController,
                                      // kwhRateController: _kwhRateController,
                                    ).signUp();

                                    if (response != null) {
                                      if (response.statusCode == 400) {
                                        await _showErrorDialog(context);
                                      } else if (response.statusCode == 201) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SetupProfile()),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedButton(
                top: 20,
                right: 15,
                buttonText: 'Sign Up',
                targetPage: LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
