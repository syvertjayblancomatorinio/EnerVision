import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/confirm_delete.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/post_view_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyEfficiency/Community/create_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/EnergyEfficiency/Community/ellipse_icon.dart';
import 'package:supabase_project/EnergyEfficiency/Community/empty_post_page.dart';
import 'package:supabase_project/EnergyEfficiency/Community/suggestion_list.dart';
import 'package:supabase_project/EnergyEfficiency/Community/top_bar.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';

import '../../PreCode/deleteDialog.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  AppControllers controller = AppControllers();
  final AppControllers controllers = AppControllers();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool showUsersPosts = false;
  bool isUserPost = false;
  String placeholderImage = 'assets/image (6).png';

  int? activeSuggestionIndex;
  int? _tappedIndex;
  int? editingIndex;

  String? username;
  String postId = '';
  String? error;

  List<TextEditingController> editControllers = [];

  List<Map<String, dynamic>> posts = [];
  // final List<Map<String, dynamic>> suggestions = [
  //   {
  //     "_id": "671e3d05844b1bfce7281304",
  //     "userId": {"_id": "670a08e4f579c8fb68fe47a7", "username": "User1"},
  //     "suggestionText": "This is the first suggestion.",
  //     "suggestionDate": "2024-11-20T14:00:00.000Z",
  //   },
  //   {
  //     "_id": "671e3d05844b1bfce7281305",
  //     "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
  //     "suggestionText":
  //         "This is the second suggestion with more text for testing.",
  //     "suggestionDate": "2024-11-21T09:30:00.000Z",
  //   },
  //   {
  //     "_id": "671e3d05844b1bfce7281305",
  //     "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
  //     "suggestionText":
  //         "This is the second suggestion with more text for testing.",
  //     "suggestionDate": "2024-11-21T09:30:00.000Z",
  //   },
  //   {
  //     "_id": "671e3d05844b1bfce7281305",
  //     "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
  //     "suggestionText":
  //         "This is the second suggestion with more text for testing.",
  //     "suggestionDate": "2024-11-21T09:30:00.000Z",
  //   },
  //   {
  //     "_id": "671e3d05844b1bfce7281305",
  //     "userId": {"_id": "670a08e4f579c8fb68fe47a8", "username": "User2"},
  //     "suggestionText":
  //         "This is the second suggestion with more text for testing.",
  //     "suggestionDate": "2024-11-21T09:30:00.000Z",
  //   },
  // ];
  late List<Map<String, dynamic>> suggestions = [];
  static const String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: <Widget>[
          TopBar(onEditTap: () {
            _showActionSheet(context);
          }, onRefreshTap: () {
            getPosts();
          }),
          _content(),
        ],
      ),
    );
  }

  Widget _content() {
    List<dynamic> sortedPosts = List.from(posts);
    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });

    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const Center(
                  child: LoadingWidget(
                message: 'Getting Post',
                color: AppColors.primaryColor,
              ))
            else if (sortedPosts.isEmpty)
              const Center(child: Body())
            else
              ...sortedPosts.asMap().entries.map((entry) {
                var post = entry.value;
                int index = entry.key;
                return _buildUserPost(
                  // post['username'] ?? username ?? 'Unknown User',
                  username ?? post['username'] ?? 'Unknown User',
                  post['title'] ?? 'No Title',
                  post['description'] ?? 'No Description',
                  post['timeAgo'] ?? 'Some time ago',
                  post['tags'] ?? 'No tags',
                  '',
                  '',

                  index,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPost(
    String username,
    String title,
    String description,
    String timeAgo,
    String tags,
    String profileImageUrl,
    String postImageUrl,
    int index,
  ) {
    List<dynamic> sortedPosts = List.from(posts);
    final post = posts[index];

    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });
    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;

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
                  BuildAvatar(
                    profileImageUrl: profileImageUrl,
                  ),
                  const SizedBox(width: 10.0),
                  _buildTitleTags(username, tags),
                  const Spacer(),
                  _buildTags(timeAgo),
                  const SizedBox(width: 10.0),
                  BuildIcon(
                    index: index,
                    onTap: (index) {
                      _editPostActionSheet(context, index);
                    },
                  )
                ],
              ),
              BuildTitle(title: title),
              BuildDescription(description: description),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: CircleAvatar(
                          radius: 10.0,
                          backgroundImage: NetworkImage(validProfileImageUrl),
                          child: ClipOval(
                            child: Image.network(
                              validProfileImageUrl,
                              width: 20.0,
                              height: 20.0,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Image.asset(
                                  placeholderImage,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_tappedIndex == index) {
                              _tappedIndex = null;
                            } else {
                              postId = post['id'];
                              fetchSuggestions(postId);
                              _tappedIndex = index;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1BBC9B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          _tappedIndex == index
                              ? 'Hide Suggestions'
                              : 'Add Suggestions',
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (_tappedIndex == index) _buildSuggestionTextField(index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionTextField(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
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
                    controller: controller.suggestionController,
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
                  onPressed: () async {
                    addSuggestionFunction(index);
                    fetchSuggestions(postId);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          // Scrollable suggestions list
          SizedBox(
            height: 200.0, // Limit the height to make it scrollable
            child: suggestionsList(),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSuggestions(String postId) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final suggestionsData = await PostsService.getComments(postId);
      setState(() {
        suggestions = suggestionsData;
        print(
          'suggestions data loaded $suggestionsData',
        );
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        error = 'Failed to load suggestions. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget suggestionsList() {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
        trackColor: WidgetStateProperty.all(Colors.grey[300]), // Track color
        trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(10), // Adjust thickness
        radius: const Radius.circular(20), // Rounded edges
        thumbVisibility:
            WidgetStateProperty.all(true), // Always show the scrollbar
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return Container(
              padding: const EdgeInsets.only(left: 15, bottom: 5),
              margin: const EdgeInsets.symmetric(vertical: 5),
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
                        suggestion['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color(0xFF1BBC9B),
                        ),
                      ),
                      const Spacer(),
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
                      ),
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
                  // Text(
                  //   "Commented on: ${DateTime.parse(suggestion['suggestionDate']).toLocal()}",
                  //   style: const TextStyle(
                  //     fontSize: 12.0,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void addSuggestionFunction(int index) async {
    final suggestionText =
        toSentenceCase(controller.suggestionController.text.trim());

    if (suggestionText.isEmpty) {
      showSnackBar(context, 'Suggestion text cannot be empty');
      return;
    }

    try {
      // Retrieve user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        showSnackBar(context, 'User not logged in');
        return;
      }

      // Get postId (assume posts[index] contains the postId)
      final postId = posts[index]['id'] ?? posts[index]['_id'];

      // Construct the API URL
      final url = Uri.parse('$baseUrl/addSuggestionToPost/$postId/suggestions');

      // Prepare the data for the POST request
      final body = jsonEncode({
        'userId': userId,
        'suggestionText': suggestionText,
      });

      // Send the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        showSnackBar(context, 'Suggestion added successfully to $postId');
        print('Suggestion added successfully to $postId');
        controller.suggestionController.clear(); // Clear the text field
      } else {
        final responseData = jsonDecode(response.body);
        showSnackBar(
            context, 'Failed to add suggestion: ${responseData['message']}');
      }
    } catch (e) {
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  Widget _buildTags(String tags) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        tags,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTitleTags(String title, String tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [BuildTitle(title: title), BuildTags(tags: tags)],
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await PostsService.deleteAPost(postId);
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting appliance: $e');
    }
  }

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
      isUserPost = false; // Remove this if unused
    });

    try {
      final List<Map<String, dynamic>>? fetchedPosts =
          await PostsService.getPosts();
      if (fetchedPosts != null) {
        setState(() {
          posts = fetchedPosts;
        });
      } else {
        throw Exception('Invalid post data format.');
      }
    } catch (e) {
      print('Failed to fetch posts: $e');
      showSnackBar(context, 'Failed to fetch posts. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUsersPost() async {
    setState(() {
      isLoading = true;
      isUserPost = true;
    });
    try {
      final fetchedData = await PostsService.fetchUsersPosts();
      setState(() {
        posts = List<Map<String, dynamic>>.from(fetchedData['posts']);
        username = fetchedData['username'];
      });
    } catch (e) {
      print('Failed to fetch posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showPostDialog(int index) {
    var post = posts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PostViewDialog(
          post: post,
        );
      },
    );
  }

  void _confirmDeletePost(int index) {
    if (index < 0 || index >= posts.length || posts[index]['_id'] == null) {
      print('Invalid index or missing post ID for deletion');
      return;
    }

    final postId = posts[index]['_id'];
    print('Attempting to delete post with ID: $postId');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          title: 'Delete Post?',
          description: 'Are you sure you want to delete this post?',
          onDelete: () => deletePost(postId),
          postDelete: getUsersPost,
        );
      },
    );
  }

  void _togglePostView() {
    setState(() {
      showUsersPosts = !showUsersPosts;
      if (showUsersPosts) {
        getUsersPost();
      } else {
        getPosts();
      }
    });
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShareYourStoryPage()),
              );
            },
            child: const Text('Create a new post'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _togglePostView();
            },
            child: const Text('View All My Posts'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }

  void _editPostActionSheet(BuildContext context, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              if (isUserPost) {
                _confirmDeletePost(index);
              } else {
                _confirmReportPost(index);
              }
            },
            child: isUserPost
                ? const Text('Delete Post')
                : const Text('Report Post'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
                // color: Colors.redAccent,
                ),
          ),
        ),
      ),
    );
  }

  void _confirmReportPost(int index) {
    final post = posts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          title: 'Report Post?',
          description: 'Are you sure you want to Report this Post? ',
          onDelete: () => deletePost(post['_id']).then(
            (_) {},
          ),
          postDelete: getPosts,
        );
      },
    );
  }
}
