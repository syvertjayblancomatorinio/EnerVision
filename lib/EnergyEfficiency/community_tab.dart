import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_profile.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyEfficiency/create_post.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:supabase_project/PreCode/deleteDialog.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  AppControllers controller = AppControllers();
  List<TextEditingController> editControllers = [];

  List<dynamic> posts = [];
  bool isLoading = false;
  bool showUsersPosts = false;
  bool isUserPost = false;
  List<String> suggestions = [];
  String placeholderImage = 'assets/image (6).png';
  int? activeSuggestionIndex;
  int? _tappedIndex;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> deletePost(String postId) async {
    try {
      await PostsService.deletePost(postId);
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  void _confirmDeletePost(int index) {
    final post = posts[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning, // Warning icon for deletion
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Post?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to delete this Post? This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deletePost(post['_id']).then((_) {
                          Navigator.of(context).pop();
                          getPosts();
                        }).catchError((error) {
                          // Handle error if deletion fails
                          print('Deletion failed: $error');
                          Navigator.of(context)
                              .pop(); // Close dialog even on error
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
      isUserPost = false;
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

  Future<void> getUsersPost() async {
    setState(() {
      isLoading = true;
      isUserPost = true;
    });

    try {
      final fetchedPosts = await PostsService.fetchUsersPosts();
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
              _confirmDeletePost(index);
            },
            child: const Text('Delete Post'),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          _buildTopBar(),
          _content(),
        ],
      ),
    );
  }

  Widget _content() {
    List<dynamic> sortedPosts = List.from(posts);
    sortedPosts.sort((a, b) {
      String timeAgoA = a['timeAgo'] ?? '';
      String timeAgoB = b['timeAgo'] ?? '';
      return timeAgoB.compareTo(timeAgoA);
    });

    return Column(
      children: <Widget>[
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (sortedPosts.isEmpty)
          Center(
            child: _buildBody(),
          )
        else
          ...sortedPosts.asMap().entries.map((entry) {
            var post = entry.value;
            int index = entry.key; // Get the index
            return _buildUserPost(
              post['title'] ?? 'No Title',
              post['description'] ?? 'No Description',
              post['timeAgo'] ?? 'Some time ago',
              post['tags'] ?? 'No tags',
              'https://example.com/user_avatar.jpg',
              'https://example.com/sample_image.jpg',
              index, // Pass the index here
            );
          }).toList(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: greyBoxDecoration(),
        width: double.infinity,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share your insight',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(width: 10.0),
            GestureDetector(
              onTap: () {
                _showActionSheet(context);
              },
              child: const Icon(Icons.edit),
            ),
            GestureDetector(
              onTap: () {
                getPosts();
              },
              child: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildTags(String tags) {
    return Text(
      tags,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  Widget _buildTitleTags(String title, String tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(title),
        const SizedBox(height: 4.0),
        _buildTags(tags),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 10, bottom: 10),
      child: Text(
        description,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildAvatar(String profileImageUrl, String postImageUrl) {
    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;
    return CircleAvatar(
      radius: 20.0,
      backgroundImage: NetworkImage(validProfileImageUrl),
      child: ClipOval(
        child: Image.network(
          validProfileImageUrl,
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return Image.asset(
              placeholderImage,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    return GestureDetector(
        onTap: () {
          _editPostActionSheet(context, index);
        },
        child: const Icon(Icons.more_vert));
  }

  Widget _buildPostImage(
    String profileImageUrl,
    String postImageUrl,
  ) {
    final String validPostImageUrl =
        postImageUrl.isNotEmpty ? postImageUrl : placeholderImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        validPostImageUrl,
        width: double.infinity,
        height: 200.0,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset(
            placeholderImage,
            width: double.infinity,
            height: 200.0,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildSuggestionsButton(String profileImageUrl, int index) {
    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;
    return Row(
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
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (_tappedIndex == index) {
                _tappedIndex =
                    null; // Hide the text field if the same post is tapped again
              } else {
                _tappedIndex = index; // Set the tapped index
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1BBC9B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('Add Suggestions'),
        ),
      ],
    );
  }

  Widget _buildUserPost(
    String title,
    String description,
    String timeAgo,
    String tags,
    String profileImageUrl,
    String postImageUrl,
    int index, // Pass the index
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: greyBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(
                  profileImageUrl,
                  postImageUrl,
                ),
                const SizedBox(width: 10.0),
                _buildTitleTags(title, tags),
                const Spacer(),
                _buildTags(timeAgo),
                const SizedBox(width: 10.0),
                _buildIcon(index),
              ],
            ),
            _buildDescription(description),
            const SizedBox(height: 10.0),
            _buildSuggestionsButton(postImageUrl, index),
            if (_tappedIndex == index) _buildSuggestionTextField(),
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
            onPressed: () {
              if (controller.suggestionController.text.isNotEmpty) {
                setState(() {
                  suggestions.add(controller.suggestionController.text);
                  controller.suggestionController.clear();
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
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
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
                  const Text(
                    'Juan Dela Cruz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1BBC9B),
                      fontSize: 16.0,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
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
                          // _saveEdit(value, index);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        // _saveEdit(editControllers[index].text, index);
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
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/add_post 1.png',
              width: 150.0,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Nothing Here Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Add a post or insight to see content from others.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShareYourStoryPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C29A),
                padding:
                    const EdgeInsets.symmetric(horizontal: 100.0, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Add Post',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
