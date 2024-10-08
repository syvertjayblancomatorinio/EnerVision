import 'package:flutter/material.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  final String username;

  LandingPage({required this.username});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _formKey = GlobalKey<FormState>();
  final _countryLineController = TextEditingController();
  final _cityLineController = TextEditingController();
  final _streetLineController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  File? _profilePicture;
  late BuildContext context;
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePicture = File(pickedFile.path);
        });
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // Retrieve the user ID

      if (userId != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:8080/updateProfile'),
        );

        request.fields['userId'] = userId; // Pass the user ID
        request.fields['countryLine'] = _countryLineController.text;
        request.fields['cityLine'] = _cityLineController.text;
        request.fields['streetLine'] = _streetLineController.text;
        request.fields['mobileNumber'] = _mobileNumberController.text;

        if (_profilePicture != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'profilePicture',
            _profilePicture!.path,
            filename: basename(_profilePicture!.path),
          ));
        }

        try {
          final response = await request.send();

          if (response.statusCode == 200) {
            print('Profile updated successfully');
          } else {
            print('Failed to update profile: ${response.reasonPhrase}');
          }
        } catch (e) {
          print('Exception occurred: $e');
        }
      } else {
        print('User ID not found');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 200,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/deviceImage.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, ${widget.username}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('Login'),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _countryLineController,
                        decoration: const InputDecoration(labelText: 'Country'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your country' : null,
                      ),
                      TextFormField(
                        controller: _cityLineController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your city' : null,
                      ),
                      TextFormField(
                        controller: _streetLineController,
                        decoration: const InputDecoration(labelText: 'Street'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your street' : null,
                      ),
                      TextFormField(
                        controller: _mobileNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Mobile Number'),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your mobile number'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Select Profile Picture'),
                      ),
                      _profilePicture != null
                          ? Image.file(_profilePicture!)
                          : const Text('No image selected'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Update Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countryLineController.dispose();
    _cityLineController.dispose();
    _streetLineController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }
}
