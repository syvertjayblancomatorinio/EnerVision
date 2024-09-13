import 'dart:io'; // Corrected import from 'dart:html' to 'dart:io'
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfile extends StatefulWidget {
  final String username;

  const SetupProfile({super.key, required this.username});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  File? _profilePicture;
  final _formKey = GlobalKey<FormState>();
  final _countryLineController = TextEditingController();
  final _cityLineController = TextEditingController();
  final _streetLineController = TextEditingController();
  final _mobileNumberController = TextEditingController();

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
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        body: _content(),
      ),
    );
  }

  Widget _content() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/energy1.png"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            // Placeholder for the rest of the content
            SizedBox(height: 100), // Adjust this height as needed
          ],
        ),
        Positioned(
          top: 250, // Adjust the value to control the overlap
          left: 0,
          right: 0,
          child: _formBox(),
        ),
      ],
    );
  }

  Widget _formBox() {
    return SingleChildScrollView(
      child: Container(
        decoration: greyBoxDecoration(),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80, // Adjust the size as needed
                  backgroundImage: _profilePicture != null
                      ? FileImage(_profilePicture!)
                      : const AssetImage('assets/profile (2).png')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.camera_alt, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Customize Your Account'),
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
