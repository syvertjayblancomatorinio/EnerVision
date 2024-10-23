import 'package:flutter/material.dart';
import 'package:supabase_project/PreCode/deleteDialog.dart';

import '../CommonWidgets/bottom-navigation-bar.dart';

class SuggestionExample extends StatefulWidget {
  @override
  _SuggestionExampleState createState() => _SuggestionExampleState();
}

class _SuggestionExampleState extends State<SuggestionExample> {
  TextEditingController suggestionController = TextEditingController();
  List<String> suggestions = [];
  List<TextEditingController> editControllers = [];
  int? editingIndex;

  @override
  void dispose() {
    for (var controller in editControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Suggestion Text Field Example'),
          backgroundColor: Color(0xFF00C29A),
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
        body: Column(
          children: [
            _buildSuggestionTextField(),
            Expanded(child: _buildSuggestionsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionTextField() {
    return Container(
      margin: const EdgeInsets.all(18.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2.0),
            child: Image(
              image: AssetImage('assets/suggestion.png'),
              width: 50.0,
              height: 50.0,
            ),
          ),
          const SizedBox(width: 5.0),
          Expanded(
            child: TextField(
              controller: suggestionController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Suggest changes or additional tips...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send_rounded,
              color: Color(0xFF1BBC9B),
              size: 24,
            ),
            onPressed: () {
              if (suggestionController.text.isNotEmpty) {
                setState(() {
                  suggestions.add(suggestionController.text);
                  suggestionController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
          padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Juan Dela Cruz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1BBC9B),
                      fontSize: 16.0,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz),
                    onSelected: (String value) {
                      if (value == 'Edit') {
                        setState(() {
                          editingIndex = index;
                          if (editControllers.length <= index) {
                            editControllers.add(TextEditingController(
                                text: suggestions[index]));
                          }
                        });
                      } else if (value == 'Delete') {
                        showDeleteConfirmationDialog(
                          context: context,
                          suggestion: suggestions[index],
                          onDelete: () {
                            setState(() {
                              suggestions.removeAt(index);
                            });
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              if (editingIndex == index)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: editControllers[index],
                        onSubmitted: (value) {
                          _saveEdit(value, index);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        _saveEdit(editControllers[index].text, index);
                      },
                    ),
                  ],
                )
              else
                Text(
                  suggestions[index],
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  void _saveEdit(String value, int index) {
    setState(() {
      suggestions[index] = value;
      editingIndex = null;
    });
  }
}
