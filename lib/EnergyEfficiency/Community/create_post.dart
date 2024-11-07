import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/EnergyEfficiency/Community/energy_effieciency_page.dart';
import '../../CommonWidgets/dialogs/error_dialog.dart';

class ShareYourStoryPage extends StatefulWidget {
  @override
  _ShareYourStoryPageState createState() => _ShareYourStoryPageState();
}

class _ShareYourStoryPageState extends State<ShareYourStoryPage> {
  XFile? _image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final int _clickCount = 0;
  final int _clickLimit = 1;
  final List<String> tags = [
    'Renewable Energy',
    'Solar Energy',
    'Green Living',
    'Energy Conservation',
  ];

  List<dynamic> posts = [];
  List<bool> selectedTags = List.filled(4, false);
  List<String> finalSelectedTags = [];

  bool isLoading = false;
  String displayTag = 'Search or Choose a Tag';
  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> createPost(
      String currentUserId, Map<String, dynamic> postData) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final url = Uri.parse("http://10.0.2.2:8080/addPost");

    String tagsAsString = postData['tags'].join(',');

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'postData': {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'tags': tagsAsString,
        }
      }),
    );

    if (response.statusCode == 400) {
      await _showApplianceErrorDialog(context);
    } else if (response.statusCode == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const EnergyEfficiencyPage(selectedIndex: 1)),
      );

      print('Post added successfully');
    } else {
      print('Failed to add post: ${response.body}');
    }
  }

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final fetchedPosts = await PostsService.getPosts();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Failed to fetch posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Post not Added',
      message: 'There was an error adding your post.',
      buttonText: 'OK',
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  void _validateInputs() {
    setState(() {});
  }

  bool _isValidInput() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: customAppBar1(
          title: 'Share Your Story',
          showTitle: true,
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleSection(),
              const SizedBox(height: 20),
              _buildDescriptionSection(),
              const SizedBox(height: 20),
              _buildTagSection(context),
              const SizedBox(height: 20),
              _buildPhotoContainer(),
              const SizedBox(height: 20),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style:
              TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Add a Title',
            hintStyle: const TextStyle(
                fontFamily: 'Montserrat', color: Colors.grey, fontSize: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style:
              TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add a Description',
            hintStyle: const TextStyle(
                fontFamily: 'Montserrat', color: Colors.grey, fontSize: 12.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTagSelectionDialog(context);
      },
      child: Row(
        children: [
          const Icon(Icons.label_outline, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              displayTag,
              style:
                  const TextStyle(color: Colors.grey, fontFamily: 'Montserrat'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTagSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select or Choose a Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tags.length, (index) {
                return RadioListTile<String>(
                  title: Text(tags[index]),
                  value: tags[index],
                  groupValue: displayTag,
                  onChanged: (String? value) {
                    setState(() {
                      displayTag = value!;
                      finalSelectedTags.clear();
                      finalSelectedTags.add(value);
                      Navigator.of(context).pop();
                    });
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoContainer() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[100],
        ),
        child: Center(
          child: _image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Tap to choose or add a Photo',
                      style: TextStyle(
                          color: Colors.grey, fontFamily: 'Montserrat'),
                    ),
                  ],
                )
              : Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_isValidInput()) {
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getString('userId');

            Map<String, dynamic> postData = {
              'title': _titleController.text,
              'description': _descriptionController.text,
              'tags': finalSelectedTags,
            };

            await createPost(userId!, postData);
          } else {
            _validateInputs();
            if (_titleController.text.trim().isEmpty) {
              _titleController.text = 'Please add a title.';
            }
            if (_descriptionController.text.trim().isEmpty) {
              _descriptionController.text = 'Please add a description.';
            }
            if (_clickCount >= _clickLimit) {
              Text(
                'Button disabled after $_clickLimit clicks!',
                style: const TextStyle(color: Colors.red),
              );
            }

            await _showApplianceErrorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Upload'),
      ),
    );
  }
}
