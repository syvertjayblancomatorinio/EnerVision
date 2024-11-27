import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/loading_page.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:supabase_project/MainFolder/secondaryMain.dart';
import 'dart:convert';

import '../AuthService/preferences.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  File? _profilePicture;
  final _formKey = GlobalKey<FormState>();
  final _cityLineController = TextEditingController();
  final _streetLineController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String? _selectedCountry = 'Philippines';

  final List<String> city = ['Cebu City'];

  Future<void> _pickDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
          DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1900),
      lastDate: DateTime(
          DateTime.now().year - 18, DateTime.now().month, DateTime.now().day),
    );
    if (selectedDate != null) {
      setState(() {
        _birthDateController.text =
            "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}";
      });
    }
  }

  // Function to pick an image
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

  // Function to submit the form
  Future<void> _submitForm(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID is not available.');
      return;
    }
    String? token = await getToken();

    final url = Uri.parse("http://10.0.2.2:8080/updateUserProfile");
    if (token != null) {
      try {
        String fullName = toTitleCase(_nameController.text.trim());
        String? token = await getToken();
        if (token != null) {
          var response = await http.post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, dynamic>{
              'userId': userId,
              'name': fullName,
              'birthDate': _birthDateController.text,
              'mobileNumber': _mobileNumberController.text,
              'address': {
                'countryLine': _selectedCountry,
                'cityLine': _cityLineController.text,
                'streetLine': _streetLineController.text,
              },
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            var profileData = jsonDecode(response.body);
            print('Profile updated successfully: ${profileData['message']}');
            await prefs.setString('name', _nameController.text);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          } else {
            print('Failed to update profile: ${response.body}');
          }
        }
      } catch (e) {
        print('Error occurred while updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: Scaffold(
        body: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/image (6).png',
                  height: 180,
                  width: 500.0,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1D1D1), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 80.0,
                backgroundImage: _profilePicture != null
                    ? FileImage(_profilePicture!)
                    : const AssetImage('assets/profile (2).png')
                        as ImageProvider,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD1D1D1),
                      width: 1.0,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Color(0xFF00A991)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Title
        const Text(
          'Customize Your Account',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              padding: const EdgeInsets.all(5),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Name *',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    // Full Name Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Full Name',
                          hintStyle: TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 14.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your full name';
                          }
                        },
                      ),
                    ),

                    // Validator message (conditionally shown based on form validation)

                    const SizedBox(height: 5.0),

                    const Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _birthDateController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month_rounded),
                            onPressed: () => _pickDate(context),
                          ),
                          hintText: 'MM/DD/YYYY',
                          hintStyle: const TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 14.0,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty
                            ? 'Please select your birth date'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Country',
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5.0),
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          countryListTheme: const CountryListThemeData(
                              flagSize: 25,
                              backgroundColor: Colors.white,
                              textStyle: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                              bottomSheetHeight: 700,
                              inputDecoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText:
                                      'Start typing to Search your country')),
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country.name;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountry ?? 'Select Country',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.map_rounded),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'City',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Grey border
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _cityLineController.text.isEmpty
                            ? null
                            : _cityLineController.text,
                        onChanged: (newValue) {
                          setState(() {
                            _cityLineController.text = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items:
                            city.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          return value == null || value.isEmpty
                              ? 'Please select your City'
                              : null;
                        },
                        hint: Text(
                          _cityLineController.text.isEmpty
                              ? 'Select City'
                              : _cityLineController.text,
                          style: const TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Barangay or Street',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // Grey border
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _streetLineController.text.isEmpty
                            ? null
                            : _streetLineController.text,
                        onChanged: (newValue) {
                          setState(() {
                            _streetLineController.text = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items: barangays
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                              ),
                            ),
                          );
                        }).toList(),
                        validator: (value) => value == null
                            ? 'Please select your Barangay or Street'
                            : null,
                        hint: Text(
                          _streetLineController.text.isEmpty
                              ? 'Select Barangay or Street'
                              : _cityLineController.text,
                          style: const TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Phone Number',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _mobileNumberController,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                        keyboardType: TextInputType.phone,
                        maxLength:
                            10, // Adjusted to 10 digits since +63 is included
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your Phone Number',
                          hintStyle: TextStyle(
                            color: Color(0xFF969696),
                            fontSize: 14.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          counterText: '',
                          prefixText: '+63 ', // Adding country code as prefix
                          prefixStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'Please enter a valid phone number (numbers only)';
                          } else if (value.length != 10) {
                            return 'Phone number must be 10 digits'; // Changed to 10 digits
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _submitForm(context);
                          }
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C29A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cityLineController.dispose();
    _streetLineController.dispose();
    _mobileNumberController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}
