import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyEfficiency/Community/see_more.dart';
import 'package:supabase_project/EnergyEfficiency/widgets.dart';
import 'package:supabase_project/PreCode/deleteDialog.dart';
import '../CommonWidgets/bottom-navigation-bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionExample extends StatefulWidget {
  @override
  _SuggestionExampleState createState() => _SuggestionExampleState();
}

class _SuggestionExampleState extends State<SuggestionExample> {
  TextEditingController suggestionController = TextEditingController();
  List<String> suggestions = []; // Store suggestions here

  @override
  void dispose() {
    suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: customAppBar1(
          showBackArrow: true,
          showTitle: false,
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  // _tappedPostIndex = _tappedPostIndex == 0 ? null : 0;
                });
              },
              child: _buildUserPost('Title', 'Description', 'Time Ago', 'Tags',
                  'ProfileImageUrl', 'PostImageUrl', 0),
            ),
            _buildSuggestionList(), // Display suggestions below
          ],
        ),
      ),
    );
  }

  // Widget for displaying suggestions list below the TextField
  Widget _buildSuggestionList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
        );
      },
    );
  }

  Widget _buildUserPost(
    String title,
    String description,
    String timeAgo,
    String tags,
    String profileImageUrl,
    String postImageUrl,
    int index,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: greyBoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Avatar(profileImageUrl: 'assets/placeholder.png'),
                  const SizedBox(width: 10.0),
                  TitleTags(title: title, tags: tags),
                  const Spacer(),
                  _buildTags(timeAgo),
                  const SizedBox(width: 10.0),
                  _buildIcon(index),
                ],
              ),
              _buildDescription(description),
              const SizedBox(height: 10.0),
              SuggestionTextField(
                controller: suggestionController,
                hintText: 'Enter your suggestion...',
                imagePath: 'assets/suggestion.png',
                borderColor: Colors.blueGrey,
                iconColor: AppColors.secondaryColor,
                onSend: _addSuggestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle adding a suggestion
  void _addSuggestion() {
    if (suggestionController.text.isNotEmpty) {
      setState(() {
        suggestions.add(suggestionController.text); // Add to local list
      });
      suggestionController.clear();

      // Send suggestion to the backend
      // You may want to replace this with your actual API call
      sendSuggestionToPost(suggestionController.text);
    }
  }

  Widget _buildTags(String tags) {
    return Text(
      tags,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  Widget _buildDescription(String description) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
          child: CustomReadMoreText(
            text: description,
            trimLines: 2,
            trimCollapsedText: 'Show more',
            trimExpandedText: 'Show less',
            moreStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    return GestureDetector(
      onTap: () {
        // _editPostActionSheet(context, index);
      },
      child: const Icon(Icons.more_vert),
    );
  }

  Future<void> sendSuggestionToPost(String suggestion) async {
    // Example API call to backend to add suggestion to post
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final postId = prefs.getString('postId');
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/addSuggestions/${postId}'),
        body: {'suggestionData': suggestion, 'userId': userId},
      );
      if (response.statusCode == 201) {
        print('Suggestion added successfully');
      } else {
        print('Failed to add suggestion');
      }
    } catch (e) {
      print('Error adding suggestion: $e');
    }
  }
}
