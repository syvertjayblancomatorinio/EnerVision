import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/AuthService/auth_suggestions.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/community_guidelines_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/confirm_delete.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/post_view_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:event_bus/event_bus.dart';
import 'package:supabase_project/EnergyManagement/Community/create_post.dart';
import 'package:supabase_project/EnergyManagement/Community/ellipse_icon.dart';
import 'package:supabase_project/EnergyManagement/Community/empty_post_page.dart';
import 'package:supabase_project/EnergyManagement/Community/top_bar.dart';
import 'package:supabase_project/PreCode/community_guidelines.dart';

import '../../AuthService/models/user_model.dart';
import '../../AuthService/services/user_service.dart';

class CommunityTabBlurred extends StatefulWidget {
  const CommunityTabBlurred({super.key});

  @override
  State<CommunityTabBlurred> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTabBlurred> {
  bool isCommunityGuidelinesAccepted = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    getPostsFromApi();
  }

  Future<void> _acceptCommunityGuidelines() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser!.userId.isEmpty) {
      throw Exception('User ID not found in shared preferences');
    }

    try {
      final url =
          '${ApiConfig.baseUrl}/acceptCommunityGuideLines/${currentUser.userId}';
      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCommunityGuidelinesAccepted', true);
        setState(() {
          isCommunityGuidelinesAccepted = true;
        });

        print('Community Guidelines accepted successfully.');
      } else {
        print('Failed to update guidelines status. Error: ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _acceptCommunityGuidelines: $e');
      _showErrorSnackBar('Error accepting guidelines.');
    }
  }

  Future<bool> _checkCommunityGuidelinesStatus() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser!.userId.isEmpty) {
      _showErrorSnackBar('User ID not found hahah.');
      // throw Exception('User ID not found in shared preferences');
      return false;
    }

    try {
      final url =
          '${ApiConfig.baseUrl}/getCommunityGuidelines/${currentUser.userId}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final isJson =
            response.headers['content-type']?.contains('application/json') ??
                false;
        if (isJson) {
          final data = json.decode(response.body);
          final accepted = data['accepted'] ?? false;

          if (mounted) {
            setState(() {
              isCommunityGuidelinesAccepted = accepted;
            });
          }

          return accepted;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to fetch status. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking guidelines: ${e.runtimeType}, ${e.toString()}');
      _showErrorSnackBar(
          'Unable to fetch guidelines status. Please try again.');
      return false;
    }
  }

  void _showCommunityGuidelinesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CommunityGuidelinesDialog(
          onAccept: () async {
            await _acceptCommunityGuidelines();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      IgnorePointer(
        ignoring: !isCommunityGuidelinesAccepted,
        child: Opacity(
          opacity: isCommunityGuidelinesAccepted ? 1.0 : 0.5,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: <Widget>[
                TopBar(
                  onEditTap: () {
                  },
                  onRefreshTap: () {
                    if (isCommunityGuidelinesAccepted) getPostsFromApi();
                  },
                ),
                _content(),
              ],
            ),
          ),
        ),
      ),
      if (!isCommunityGuidelinesAccepted)
        GestureDetector(
          onTap: () {
            _showCommunityGuidelinesDialog();
          },
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 50.0, left: 20.0, right: 20.0),
                      child: Container(
                        width: 300.0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 50,
                              color: Colors.blueGrey[800],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Community Guidelines',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Please accept the Community Guidelines to proceed.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                _showCommunityGuidelinesDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 24.0,
                                ),
                              ),
                              child: const Text(
                                'Review Guidelines',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (isCommunityGuidelinesAccepted)
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: ElevatedButton(
            onPressed: () {
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
            ),
            child: const Icon(
              Icons.add,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
    ]);
  }

  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      await SuggestionService.deleteSuggestion(suggestionId);
      print('Suggestion deleted successfully');
    } catch (e) {
      print("Error deleting Suggestion: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> getPostsFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch posts directly from the API
      final List<Map<String, dynamic>>? fetchedPosts =
          await PostsService.getPosts();
      print('Fetched all posts: $fetchedPosts');

      if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
        setState(() {
          posts = fetchedPosts;
        });

        // Optionally, save the posts in Hive for future use
        var box = await Hive.openBox('postsBox');
        await box.put('allPosts', fetchedPosts);

        // Fetch suggestions for each post (only if 'id' is not null)
        for (var post in fetchedPosts) {
          String? postId = post['id']; // Assuming the post has an 'id' field

          if (postId != null) {
            // Fetch suggestions for each post with a valid 'id'
          } else {
            print('Skipping post with null id');
          }
        }
      } else {
        throw Exception('No posts found or invalid post data format.');
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

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Attempt to load posts from Hive (cached posts)
      List<Map<String, dynamic>> postsFromHive =
          await PostsService.getPostsFromHive();

      print('Fetched all from hive: $postsFromHive');

      // If no posts exist in Hive, fetch from API
      if (postsFromHive.isEmpty) {
        final List<Map<String, dynamic>>? fetchedPosts =
            await PostsService.getPosts();
        print('Fetched all posts: $fetchedPosts');
        // showSnackBar(context, 'Fetched posts from API');

        if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
          setState(() {
            posts = fetchedPosts;
          });

          // Save the fetched posts in Hive for future use
          var box = await Hive.openBox('postsBox');
          await box.clear(); // Clear previous posts if necessary

          for (var post in fetchedPosts) {
            await box.put(post['id'], post); // Each post saved under its own ID
          }

          // Fetch suggestions for each post (only if 'id' is not null)
          for (var post in fetchedPosts) {
            String? postId = post['id']; // Assuming the post has an 'id' field

            if (postId != null) {
            } else {
              print('Skipping post with null id');
            }
          }
        } else {
          throw Exception('Invalid post data format.');
        }
      } else {
        // If posts are available in Hive, display them
        setState(() {
          posts = postsFromHive;
        });

        // Fetch suggestions for each post (only if 'id' is not null)
        for (var post in postsFromHive) {
          String? postId = post['id']; // Assuming the post has an 'id' field

          if (postId != null) {
            // Fetch suggestions for each post with a valid 'id'
          } else {
            print('Skipping post with null id');
          }
        }
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


  Widget _content() {
    List<dynamic> sortedPosts = List.from(posts);

    // Sort posts by `timeAgo` (latest to oldest)
    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });

    return SizedBox(
      height: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const Center(
                child: LoadingWidget(
                  message: 'Getting Post',
                  color: AppColors.primaryColor,
                ),
              )
            else if (sortedPosts.isEmpty)
              const Center(child: Body())
            else
              ...sortedPosts.asMap().entries.map((entry) {
                var post = entry.value;
                int index = entry.key;

                // Sort suggestions by `createdAt` (latest to oldest)
                if (post['suggestions'] != null &&
                    post['suggestions'].isNotEmpty) {
                  post['suggestions'].sort((a, b) {
                    DateTime? timeA = DateTime.tryParse(a['createdAt'] ?? '');
                    DateTime? timeB = DateTime.tryParse(b['createdAt'] ?? '');
                    return (timeB ?? DateTime.now())
                        .compareTo(timeA ?? DateTime.now());
                  });
                }

                return Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: greyBoxDecoration(),
                  child: Column(
                    children: [
                      _buildUserPost(
                        post['username'] ?? 'Unknown User',
                        post['title'] ?? 'No Title',
                        post['description'] ?? 'No Description',
                        post['timeAgo'] ?? 'Some time ago',
                        post['tags'] ?? 'No tags',
                        '',
                        '',
                        index,
                      ),
                      // Only show suggestions for the current post
                      if (post['suggestions'] != null &&
                          post['suggestions'].isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(
                                  AppColors.primaryColor),
                              trackColor:
                                  WidgetStateProperty.all(Colors.grey[300]),
                              trackBorderColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              thickness: WidgetStateProperty.all(10),
                              radius: const Radius.circular(20),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: post['suggestions'].length,
                                itemBuilder: (context, suggestionIndex) {
                                  var suggestion = post['suggestions']
                                          [suggestionIndex] ??
                                      "Suggestions";
                                  return Container(
                                    padding: const EdgeInsets.only(
                                        left: 15, bottom: 5),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7.0),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              suggestion['suggestedBy'] ??
                                                  username,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                                color: Color(0xFF1BBC9B),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatDateTime(
                                                  suggestion['createdAt']),
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon:
                                                  const Icon(Icons.more_horiz),
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return {'Edit', 'Delete'}
                                                    .map((String choice) {
                                                  return PopupMenuItem<String>(
                                                    value: choice,
                                                    child: Text(choice),
                                                  );
                                                }).toList();
                                              },
                                              onSelected: (String value) async {
                                                if (value == 'Delete') {
                                                } else if (value == 'Edit') {
                                                  // Handle edit logic here
                                                  print('Edit tapped');
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          suggestion['suggestionText'] ??
                                              "Text",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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


    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopPost(username, timeAgo, tags, profileImageUrl, index),
              BuildTitle(title: title),
              BuildDescription(description: description),
              // PostImage(postImageUrl: postImageUrl),
              const SizedBox(height: 10.0),
              _buildAddSuggestions(profileImageUrl, postImageUrl, index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPost(
    String username,
    String timeAgo,
    String tags,
    String profileImageUrl,
    int index,
  ) {
    return Row(
      children: [
        BuildAvatar(
          profileImageUrl: profileImageUrl,
        ),
        const SizedBox(width: 10.0),
        TagsAndTitle(title: username, tags: tags),
        const Spacer(),
        BuildTags(tags: timeAgo),
        const SizedBox(width: 10.0),
        BuildIcon(
          index: index,
          onTap: (index) {
          },
        ),
      ],
    );
  }

  Widget _buildAddSuggestions(
    String profileImageUrl,
    String postImageUrl,
    int index,
  ) {
    final post = posts[index];

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostViewDialog(
                  post: post,
                  // suggestions: suggestions,
                  index: index, onPostsUpdated: getPostsFromApi,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1BBC9B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            'Add Suggestions',
          ),
        )
      ],
    );
  }


  Future<void> getUsersPost() async {
    setState(() {
      isLoading = true;
      isUserPost = true;
    });
    try {
      final fetchedData = await PostsService.fetchUsersPosts();
      print('Fetched data: $fetchedData'); // Log the fetched data

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




  AppControllers controller = AppControllers();
  final AppControllers controllers = AppControllers();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool showUsersPosts = false;
  bool isUserPost = false;
  String placeholderImage = 'assets/image (6).png';

  final int? _tappedIndex = 2;
  int? editingIndex;

  String? username;
  String postId = '';
  String? error;

  List<TextEditingController> editControllers = [];
  List<Map<String, dynamic>> posts = [];
  late List<Map<String, dynamic>> suggestions = [];
  String _formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return "Unknown date";
    }

    try {
      final DateTime dateTime = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        // Format as "day month year" for older dates
        return "${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}";
      }
    } catch (e) {
      print('Error parsing date: $e');
      return "Invalid date";
    }
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
}
