import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/AuthService/auth_suggestions.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/confirm_delete.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/post_view_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:event_bus/event_bus.dart';
import 'package:supabase_project/EnergyManagement/Community/top_bar.dart';

import '../../AuthService/auth_appliances.dart';
import '../../CommonWidgets/date_utils/date.dart';
import '../../ConstantTexts/image.dart';
import '../../zNotUsedFiles/post_authenticated/create_post.dart';
import 'create_post.dart';
import 'ellipse_icon.dart';
import 'empty_post_page.dart';

EventBus eventBus = EventBus();

class PostUpdatedEvent {}

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
// Controllers
  AppControllers controller = AppControllers();
  final ScrollController _scrollController = ScrollController();

// User-related state
  String? userId;
  String? username;
  String loggedUsername = defaultLoggedUsername;
  String? editingSuggestionId;

// UI state booleans
  bool isLoading = false;
  bool showUsersPosts = false;
  bool isUserPost = false;

// Other state
  String placeholderImage = defaultPlaceholderImage;
  String? error;

// Index tracking
  int? activeSuggestionIndex;
  int? _tappedIndex;
  int? editingIndex;

// Data
  late List<Map<String, dynamic>> posts = [];
  late List<Map<String, dynamic>> suggestions = [];

  @override
  void initState() {
    getPosts();
    _loadUsername();
    //
    // eventBus.on<PostUpdatedEvent>().listen((event) {
    // getPostsFromApi();
    // });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: <Widget>[
              TopBar(onEditTap: () {
                _showActionSheet(context);
              }, onRefreshTap: () {
                getPostsFromApi();
              }),
              _content(),
            ],
          ),
        ),
        Positioned(
          bottom: 40.0,
          right: 20.0,
          child: ElevatedButton(
            onPressed: () async {
              _showActionSheet(context);
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
      ],
    );
  }

  Widget _content() {
    if (isLoading) {
      // Prioritize showing the loading widget
      return const Center(
        child: LoadingWidget(
          message: 'Getting Post',
          color: AppColors.primaryColor,
        ),
      );
    }

    List<dynamic> sortedPosts = List.from(posts);

    // Sort posts by `timeAgo` (latest to oldest)
    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });

    if (sortedPosts.isEmpty) {
      return const Center(child: Body());
    }
    if (sortedPosts.isNotEmpty){
      isLoading = false;
      return SizedBox(
        height: 520,
        child: ListView.builder(
          itemCount: sortedPosts.length,
          itemBuilder: (context, index) {
            var post = sortedPosts[index];

            // Sort suggestions by `createdAt` (latest to oldest)
            if (post['suggestions'] != null && post['suggestions'].isNotEmpty) {
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
                  // Display suggestions for the current post
                  if (post['suggestions'] != null &&
                      post['suggestions'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 30, left: 10.0),
                          child: Text(
                            'Suggestions',
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: MaterialStateProperty.all(
                                  AppColors.primaryColor),
                              trackColor:
                              MaterialStateProperty.all(Colors.grey[300]),
                              trackBorderColor:
                              MaterialStateProperty.all(Colors.transparent),
                              thickness: MaterialStateProperty.all(5),
                              radius: const Radius.circular(20),
                              thumbVisibility: MaterialStateProperty.all(true),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: post['suggestions'].length,
                                itemBuilder: (context, suggestionIndex) {
                                  var suggestion =
                                      post['suggestions'][suggestionIndex] ??
                                          {};
                                  return _buildSuggestionTile(
                                    suggestion,
                                    post['username'] ?? '',
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      );
  }
    return Container();
  }

// Helper function to build suggestion tile
  Widget _buildSuggestionTile(
      Map<String, dynamic> suggestion, String username) {
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
                suggestion['suggestedBy'] ?? username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color(0xFF1BBC9B),
                ),
              ),
              const Spacer(),
              Text(
                formatDateTime(suggestion['createdAt']),
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (BuildContext context) {
                  bool isOwner = suggestion['suggestedBy'] == loggedUsername;
                  final options = isOwner ? {'Edit', 'Delete'} : {'Report'};
                  return options.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                onSelected: (String value) async {
                  if (value == 'Edit') {
                    _startEditing(
                      suggestion['id'],
                      suggestion['suggestionText'],
                    );
                  } else if (value == 'Delete') {
                    _confirmDeleteAppliance(suggestion['id']);
                    print('Deleting suggestion ${suggestion['id']}');
                  } else if (value == 'Report') {
                    print('Reporting suggestion ${suggestion['id']}');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          if (editingSuggestionId ==
              suggestion['id']) // Show TextField if editing
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 20),
                        child: Image(
                          image: AssetImage('assets/suggestionImage.png'),
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: TextField(
                          controller: controller.suggestionController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Edit your suggestions...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Color(0xFF1BBC9B),
                          size: 24,
                        ),
                        onPressed: () async {
                          _saveEditing(suggestion['id']);
                        },
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      editingSuggestionId = null;
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 5.0),
          Text(
            suggestion['suggestionText'] ?? "Text",
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  void _confirmDeleteAppliance(String suggestionId) {
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
                  Icons.warning,
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                _popupTitle('Are you sure you want to delete this suggestion?'),
                const SizedBox(height: 10),
                _popupDescription(
                  'This action cannot be undone.',
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
                      onPressed: () async {
                        print('attempting to delete suggestion $suggestionId');
                        await deleteSuggestion(suggestionId);
                        Navigator.of(context).pop();
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

    // sortedPosts.sort((a, b) {
    //   DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
    //   DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
    //   return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    // });

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
              if (_tappedIndex == index) _buildSuggestionTextField(index),
              // _buildSuggestionsList(),
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
            _editPostActionSheet(context, index);
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
                    SuggestionService.addSuggestion(
                      context: context,
                      suggestionController: controller.suggestionController,
                      posts: posts,
                      index: index,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget _popupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Widget _popupDescription(String description) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[500],
        fontFamily: 'Montserrat',
      ),
    );
  }
  Future<void> getPostsFromApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load cached posts from Hive first
      List<Map<String, dynamic>> cachedPosts = await PostsService.getPostsFromHive();

      if (cachedPosts.isNotEmpty) {
        setState(() {
          posts = cachedPosts;
        });
      }

      // Fetch posts from API in batches
      await fetchPostsInBatches();

      // Optionally, save all fetched posts to Hive for later use
      var box = await Hive.openBox('postsBox');
      await box.clear(); // Optional: Clear previous cache
      for (var post in posts) {
        await box.put(post['id'], post);
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

  Future<void> fetchPostsInBatches({int batchSize = 2}) async {
    // Fetch posts in smaller batches from the API
    setState(() {
      isLoading = true;  // Start the loading state when fetching begins
    });

    final List<Map<String, dynamic>>? fetchedPosts = await PostsService.getPosts();
    if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
      for (int i = 0; i < fetchedPosts.length; i += batchSize) {
        setState(() {
          posts.addAll(fetchedPosts.sublist(
            i,
            (i + batchSize) > fetchedPosts.length
                ? fetchedPosts.length
                : (i + batchSize),
          ));
        });

        // Allow the UI to update before continuing to the next batch
        await Future.delayed(const Duration(milliseconds: 200)); // Simulate async delay
      }
    }

    // After all batches are processed, stop the loading state
    setState(() {
      isLoading = false;
    });
  }

  // Future<void> getPosts() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Attempt to load posts from Hive (cached posts)
  //     List<Map<String, dynamic>> postsFromHive =
  //         await PostsService.getPostsFromHive();
  //     showSnackBar(context, 'Fetched posts from Hive');
  //
  //     print('Fetched all from hive: $postsFromHive');
  //
  //     if (postsFromHive.isEmpty) {
  //       await fetchPostsInBatches(batchSize: 2);
  //
  //       if (posts.isNotEmpty) {
  //         var box = await Hive.openBox('postsBox');
  //         await box.clear(); // Clear previous posts if necessary
  //
  //         for (var post in posts) {
  //           await box.put(post['id'] ?? post['_id'], post);
  //         }
  //
  //         for (var post in posts) {
  //           String? postId = post['id'] ?? post['_id'];
  //
  //           if (postId != null) {
  //             await fetchSuggestions(postId);
  //           } else {
  //             print('Skipping post with null id');
  //           }
  //         }
  //       } else {
  //         throw Exception('Invalid post data format.');
  //       }
  //     } else {
  //       setState(() {
  //         posts = postsFromHive;
  //       });
  //
  //       // Fetch suggestions for each post (only if 'id' is not null)
  //       for (var post in postsFromHive) {
  //         String? postId =
  //             post['id'] ?? post['_id']; // Assuming the post has an 'id' field
  //
  //         if (postId != null) {
  //           // Fetch suggestions for each post with a valid 'id'
  //           await fetchSuggestions(postId);
  //         } else {
  //           print('Skipping post with null id');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     getPostsFromApi();
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load cached posts from Hive first
      List<Map<String, dynamic>> cachedPosts = await PostsService.getPostsFromHive();

      if (cachedPosts.isNotEmpty) {
        setState(() {
          posts = cachedPosts;
        });
      }

      // Fetch posts from API incrementally
      await fetchPostsInBatches();

      // Save all fetched posts to Hive for later use
      var box = await Hive.openBox('postsBox');
      await box.clear(); // Optional: Clear previous cache
      for (var post in posts) {
        await box.put(post['id'], post);
      }
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      showSnackBar(context, 'Failed to load posts. Try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  // Future<void> fetchSuggestions(String postId) async {
  //   try {
  //     final List<Map<String, dynamic>>? suggestions = await PostsService.getSuggestions(postId);
  //
  //     if (suggestions != null && suggestions.isNotEmpty) {
  //       setState(() {
  //         posts = posts.map((post) {
  //           if (post['id'] == postId) {
  //             post['suggestions'] = suggestions;
  //           }
  //           return post;
  //         }).toList();
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Failed to fetch suggestions for post $postId: $e');
  //   }
  // }

  Future<void> fetchSuggestions(String postId) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final suggestionsData = await SuggestionService.getComments(postId);
      setState(() {
        suggestions = suggestionsData;
        print(
          'Suggestions data loaded for post $postId: $suggestionsData',
        );
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        error =
            'Failed to load suggestions for post $postId. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      await SuggestionService.deleteSuggestion(suggestionId);
      showSnackBar(context, 'Suggestion deleted successfully');
      print('Suggestion deleted successfully');
    } catch (e) {
      print("Error deleting Suggestion: $e");
    }
  }

  Future<void> updateSuggestion(
    TextEditingController suggestionController,
    String suggestionId,
  ) async {
    try {
      // if (updates.containsKey('applianceName')) {
      //   updates['applianceName'] = toTitleCase(updates['applianceName']);
      // }
      await SuggestionService.editSuggestion(
          context, suggestionController, suggestionId);
      showSnackBar(context, 'Update Success');
    } catch (e) {
      showSnackBar(context, 'Appliance can only be updated once a month.');
    }
  }

  void _startEditing(String suggestionId, String currentText) {
    setState(() {
      editingSuggestionId = suggestionId;
      controller.suggestionController.text = currentText;
    });
    print(suggestionId);
  }

  void _saveEditing(String suggestionId) {
    // Save the updated suggestion and clear the editing state
    updateSuggestion(controller.suggestionController, suggestionId);

    print(
        'Saving suggestion $suggestionId with text: ${controller.suggestionController.text}');
    setState(() {
      editingSuggestionId = null;
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');

    setState(() {
      loggedUsername = storedUsername ?? '[Username]';
      print('bilat $loggedUsername');
    });
  }

  Future<void> deleteUserSuggestion(String applianceId) async {
    try {
      await ApplianceService.deleteAppliance(applianceId);
      print('Appliance deleted successfully');
    } catch (e) {
      print('Error deleting appliance: $e');
    }
  }

  void _confirmDeleteSuggestion(int index) {
    // Ensure the index is valid and within the bounds of the list
    if (index < 0 || index >= suggestions.length) {
      print('Invalid index: $index. Cannot delete suggestion.');
      return;
    }

    final suggestion = suggestions[index];

    // Verify that the suggestion object has a valid '_id'
    if (suggestion == null || suggestion['_id'] == null) {
      print('No valid suggestion or _id found.');
      return;
    }

    // Show confirmation dialog for deletion
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
                  Icons.warning,
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                _popupTitle('Delete Suggestion?'),
                const SizedBox(height: 10),
                _popupDescription(
                  'Are you sure you want to delete this suggestion? This cannot be undone.',
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
                        deleteSuggestion(suggestion['_id']).then((_) {
                          Navigator.of(context).pop();
                        }).catchError((e) {
                          // Handle any errors during deletion
                          print('Error deleting suggestion: $e');
                          Navigator.of(context).pop(); // Close dialog if error
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

  Future<void> deletePost(String postId) async {
    try {
      await PostsService.deleteAPost(postId);
      showSnackBar(context, 'Post deleted successfully');
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting Post: $e');
    }
  }
  // TODO: Modify how the post are fetched to be able to add suggestion
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

  // Future<void> getPosts() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Attempt to load posts from Hive (cached posts)
  //     List<Map<String, dynamic>> postsFromHive =
  //         await PostsService.getPostsFromHive();
  //     print('Fetched all from hive: $postsFromHive');
  //
  //     // If no posts exist in Hive, fetch from API
  //     if (postsFromHive.isEmpty) {
  //       final List<Map<String, dynamic>>? fetchedPosts =
  //           await PostsService.getPosts();
  //       print('Fetched all posts: $fetchedPosts');
  //
  //       if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
  //         setState(() {
  //           posts = fetchedPosts;
  //         });
  //
  //         // Save the fetched posts in Hive for future use
  //         var box = await Hive.openBox('postsBox');
  //         await box.put('allPosts', fetchedPosts);
  //       } else {
  //         throw Exception('Invalid post data format.');
  //       }
  //     } else {
  //       // If posts are available in Hive, display them
  //       setState(() {
  //         posts = postsFromHive;
  //       });
  //     }
  //   } catch (e) {
  //     print('Failed to fetch posts: $e');
  //     showSnackBar(context, 'Failed to fetch posts. Please try again later.');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  void showPostDialog(int index) {
    var post = posts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PostViewDialog(
          post: post,
          // suggestions: suggestions,
          index: index, onPostsUpdated: getPostsFromApi,
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

      posts.clear();

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
                MaterialPageRoute(builder: (context) => const CreatePostPage()),
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
