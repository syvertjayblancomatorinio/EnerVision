import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/user.dart';
import 'package:supabase_project/buttons/sign_up_button.dart';
import 'package:supabase_project/CommonWidgets/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
  Future<void> _showErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Login Failed',
      message: "Email or Password \nis incorrect",
      buttonText: 'OK',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        // appBar: AppBar(title: const Text('Login')),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      const Image(
                        image: AssetImage('assets/sign-up.png'),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 40),
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
                            try {
                              final response = await AuthService(
                                context: context,
                                emailController: _emailController,
                                passwordController: _passwordController,
                              ).signIn();

                              if (response != null) {
                                if (response.statusCode == 401) {
                                  await _showErrorDialog(context);
                                }
                              }
                            } catch (e) {
                              _showSnackBar(
                                  'Failed to Sign In: ${e.toString()}');
                              print(e.toString());
                            }
                          } else {
                            _showSnackBar(
                                'Form validation failed. Please check your input.');
                            print('Form validation not okay');
                          }
                        },
                        text: 'Sign In',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 30.0),
                  backgroundColor: const Color(0xFF75FFBA),
                  elevation: 5.0,
                ),
                child: const Text(
                  'Sign Up',
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
    );
  }
}
