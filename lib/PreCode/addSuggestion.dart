import 'package:flutter/material.dart';

class SuggestionExample extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions = [
    {
      "_id": "671e3d05844b1bfce7281304",
      "userId": {"_id": "670a08e4f579c8fb68fe47a7", "username": "User1"},
      "suggestionText": "This is the first suggestion.",
      "suggestionDate": "2024-11-20T14:00:00.000Z",
    },
    {
      "_id": "671e3d05844b1bfce7281305",
      "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
      "suggestionText":
          "This is the second suggestion with more text for testing.",
      "suggestionDate": "2024-11-21T09:30:00.000Z",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      suggestion['userId']['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Color(0xFF1BBC9B),
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_horiz),
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 5.0),
                Text(
                  suggestion['suggestionText'],
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  "Commented on: ${DateTime.parse(suggestion['suggestionDate']).toLocal()}",
                  style: const TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
// import 'package:supabase_project/CommonWidgets/box_decorations.dart';
// import 'package:supabase_project/ConstantTexts/colors.dart';
// import 'package:supabase_project/EnergyEfficiency/Community/see_more.dart';
// import 'package:supabase_project/EnergyEfficiency/widgets.dart';
// import 'package:supabase_project/PreCode/deleteDialog.dart';
// import '../CommonWidgets/bottom-navigation-bar.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SuggestionExample extends StatefulWidget {
//   @override
//   _SuggestionExampleState createState() => _SuggestionExampleState();
// }
//
// class _SuggestionExampleState extends State<SuggestionExample> {
//   TextEditingController suggestionController = TextEditingController();
//   // List<String> suggestions = []; // Store suggestions here
//   List<TextEditingController> editControllers = [];
//
//   final List<Map<String, dynamic>> suggestions = [
//     {
//       "_id": "671e3d05844b1bfce7281304",
//       "userId": {"_id": "670a08e4f579c8fb68fe47a7", "username": "User1"},
//       "postId": "670a0ef4905db7eb08546014",
//       "suggestionText": "This is the first suggestion.",
//       "deletedAt": null,
//       "suggestionDate": "2024-11-20T14:00:00.000Z",
//       "createdAt": "2024-11-20T13:55:00.000Z",
//       "updatedAt": "2024-11-20T13:55:00.000Z",
//       "__v": 0,
//     },
//     {
//       "_id": "671e3d05844b1bfce7281305",
//       "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
//       "postId": "670a0ef4905db7eb08546014",
//       "suggestionText":
//           "This is the second suggestion with more text for testing.",
//       "deletedAt": null,
//       "suggestionDate": "2024-11-21T09:30:00.000Z",
//       "createdAt": "2024-11-21T09:25:00.000Z",
//       "updatedAt": "2024-11-21T09:25:00.000Z",
//       "__v": 0,
//     },
//   ];
//
//   @override
//   void dispose() {
//     suggestionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: customAppBar1(
//           showBackArrow: true,
//           showTitle: false,
//           showProfile: false,
//           onBackPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
//         body: Column(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   // _tappedPostIndex = _tappedPostIndex == 0 ? null : 0;
//                 });
//               },
//               child: _buildUserPost('Title', 'Description', 'Time Ago', 'Tags',
//                   'ProfileImageUrl', 'PostImageUrl', 0),
//             ),
//             _buildSuggestionsList(), // Display suggestions below
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget for displaying suggestions list below the TextField
//   // Widget _buildSuggestionList() {
//   //   return ListView.builder(
//   //     shrinkWrap: true,
//   //     itemCount: suggestions.length,
//   //     itemBuilder: (context, index) {
//   //       return ListTile(
//   //         title: Text(suggestions[index]),
//   //       );
//   //     },
//   //   );
//   // }
//
//   Widget _buildSuggestionsListNew() {
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final suggestion = suggestions[index];
//         var editingIndex;
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
//           padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(7.0),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     suggestion['userId']['username'],
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1BBC9B),
//                       fontSize: 16.0,
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.more_horiz),
//                     onSelected: (String value) {
//                       if (value == 'Edit') {
//                         setState(() {
//                           var editingIndex = index;
//                           if (editControllers.length <= index) {
//                             editControllers.add(TextEditingController(
//                                 text: suggestion['suggestionText']));
//                           }
//                         });
//                       } else if (value == 'Delete') {
//                         showDeleteConfirmationDialog(
//                           context: context,
//                           suggestion: suggestion['suggestionText'],
//                           onDelete: () {
//                             setState(() {
//                               suggestions.removeAt(index);
//                             });
//                           },
//                         );
//                       }
//                     },
//                     itemBuilder: (BuildContext context) {
//                       return {'Edit', 'Delete'}.map((String choice) {
//                         return PopupMenuItem<String>(
//                           value: choice,
//                           child: Text(choice),
//                         );
//                       }).toList();
//                     },
//                   ),
//                 ],
//               ),
//               if (editingIndex == index)
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: editControllers[index],
//                         onSubmitted: (value) {
//                           // _saveEdit(value, index);
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.check, color: Colors.green),
//                       onPressed: () {
//                         // _saveEdit(editControllers[index].text, index);
//                       },
//                     ),
//                   ],
//                 )
//               else
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       suggestion[
//                           'suggestionText'], // Display the suggestion text
//                       style: const TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 5.0),
//                     Text(
//                       "Posted on: ${DateTime.parse(suggestion['suggestionDate']).toLocal()}",
//                       style: const TextStyle(
//                         fontSize: 12.0,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSuggestionsList() {
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         var editingIndex;
//         var editControllers;
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
//           padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(7.0),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Juan Dela Cruz',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1BBC9B),
//                       fontSize: 16.0,
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.more_horiz),
//                     onSelected: (String value) {
//                       if (value == 'Edit') {
//                         // setState(() {
//                         //   editingIndex = index;
//                         //   if (editControllers.length <= index) {
//                         //     editControllers.add(TextEditingController(
//                         //         text: suggestions[index]));
//                         //   }
//                         // });
//                       } else if (value == 'Delete') {
//                         // showDeleteConfirmationDialog(
//                         //   context: context,
//                         //   // suggestion: suggestions[index],
//                         //   onDelete: () {
//                         //     setState(() {
//                         //       suggestions.removeAt(index);
//                         //     });
//                         //   },
//                         // );
//                       }
//                     },
//                     itemBuilder: (BuildContext context) {
//                       return {'Edit', 'Delete'}.map((String choice) {
//                         return PopupMenuItem<String>(
//                           value: choice,
//                           child: Text(choice),
//                         );
//                       }).toList();
//                     },
//                   ),
//                 ],
//               ),
//               if (editingIndex == index)
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: editControllers[index],
//                         onSubmitted: (value) {
//                           // _saveEdit(value, index);
//                         },
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.check, color: Colors.green),
//                       onPressed: () {
//                         // _saveEdit(editControllers[index].text, index);
//                       },
//                     ),
//                   ],
//                 )
//               else
//                 Text(
//                   suggestions[index] as String,
//                   style: const TextStyle(
//                     fontSize: 14.0,
//                     color: Colors.black,
//                   ),
//                 ),
//               const SizedBox(height: 8.0),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildUserPost(
//     String title,
//     String description,
//     String timeAgo,
//     String tags,
//     String profileImageUrl,
//     String postImageUrl,
//     int index,
//   ) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//         child: Container(
//           padding: const EdgeInsets.all(10.0),
//           decoration: greyBoxDecoration(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Avatar(profileImageUrl: 'assets/placeholder.png'),
//                   const SizedBox(width: 10.0),
//                   TitleTags(title: title, tags: tags),
//                   const Spacer(),
//                   _buildTags(timeAgo),
//                   const SizedBox(width: 10.0),
//                   _buildIcon(index),
//                 ],
//               ),
//               _buildDescription(description),
//               const SizedBox(height: 10.0),
//               SuggestionTextField(
//                 controller: suggestionController,
//                 hintText: 'Enter your suggestion...',
//                 imagePath: 'assets/suggestion.png',
//                 borderColor: Colors.blueGrey,
//                 iconColor: AppColors.secondaryColor,
//                 onSend: _addSuggestion,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Function to handle adding a suggestion
//   void _addSuggestion() {
//     if (suggestionController.text.isNotEmpty) {
//       setState(() {
//         suggestions.add(suggestionController.text
//             as Map<String, dynamic>); // Add to local list
//       });
//       suggestionController.clear();
//
//       // Send suggestion to the backend
//       // You may want to replace this with your actual API call
//       sendSuggestionToPost(suggestionController.text);
//     }
//   }
//
//   Widget _buildTags(String tags) {
//     return Text(
//       tags,
//       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//     );
//   }
//
//   Widget _buildDescription(String description) {
//     return Container(
//       constraints: const BoxConstraints(maxHeight: 300),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
//           child: CustomReadMoreText(
//             text: description,
//             trimLines: 2,
//             trimCollapsedText: 'Show more',
//             trimExpandedText: 'Show less',
//             moreStyle: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildIcon(int index) {
//     return GestureDetector(
//       onTap: () {
//         // _editPostActionSheet(context, index);
//       },
//       child: const Icon(Icons.more_vert),
//     );
//   }
//
//   Future<void> sendSuggestionToPost(String suggestion) async {
//     // Example API call to backend to add suggestion to post
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('userId');
//     final postId = prefs.getString('postId');
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8080/addSuggestions/${postId}'),
//         body: {'suggestionData': suggestion, 'userId': userId},
//       );
//       if (response.statusCode == 201) {
//         print('Suggestion added successfully');
//       } else {
//         print('Failed to add suggestion');
//       }
//     } catch (e) {
//       print('Error adding suggestion: $e');
//     }
//   }
// }
