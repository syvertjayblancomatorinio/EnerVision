import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/EnergyPage/EnergyTracker/energy_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/EnergyEfficiency/energy_effieciency_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/EnergyEfficiency/your_energy_tab.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/home_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

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
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _occupationController = TextEditingController();
  final _birthDateController = TextEditingController();

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

  Future<void> _submitForm(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID is not available.');
      return;
    }

    // Debug prints for each input
    print('UserId: $userId');
    print('Name: ${_nameController.text}');
    print('Gender: ${_genderController.text}');
    print('Occupation: ${_occupationController.text}');
    print('Birth Date: ${_birthDateController.text}');
    print('Mobile Number: ${_mobileNumberController.text}');
    print('Country: ${_countryLineController.text}');
    print('City: ${_cityLineController.text}');
    print('Street: ${_streetLineController.text}');

    final url = Uri.parse("http://10.0.2.2:8080/updateUserProfile");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'name': _nameController.text,
          'gender': _genderController.text,
          'occupation': _occupationController.text,
          'birthDate': _birthDateController.text,
          'mobileNumber': _mobileNumberController.text,
          'address': {
            'countryLine': _countryLineController.text,
            'cityLine': _cityLineController.text,
            'streetLine': _streetLineController.text,
          },
        }),
      );

      if (response.statusCode == 200) {
        // Profile update successful
        var profileData = jsonDecode(response.body);
        // Handle profile data
        // Navigate after successful update
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EnergyEffieciencyPage(
                    selectedIndex: 1,
                  )),
        );
      } else {
        // Log the response body to debug
        print('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        body: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
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
        const SizedBox(height: 20), // Space between image and form
        Expanded(
          child: SingleChildScrollView(
            child: _formBox(context),
          ),
        ),
      ],
    );
  }

  Widget _formBox(BuildContext context) {
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
                  radius: 80,
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
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    controller: _genderController,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your gender' : null,
                  ),
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(labelText: 'Occupation'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your occupation' : null,
                  ),
                  TextFormField(
                    controller: _birthDateController,
                    decoration: const InputDecoration(
                        labelText: 'Birth Date (YYYY-MM-DD)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your birth date' : null,
                  ),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm(context); // Use the context directly
                      } else {
                        // Handle the case where validation fails
                        print(
                            'Form validation failed. Please check your inputs.');
                      }
                    },
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
    _nameController.dispose();
    _genderController.dispose();
    _occupationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}
