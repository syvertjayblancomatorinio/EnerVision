import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_profile.dart';
import 'package:supabase_project/AuthService/auth_service.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/EnergyEfficiency/create_post.dart';
import 'package:http/http.dart' as http;

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  List<dynamic> posts = [];
  bool isLoading = false;
  bool showUsersPosts = false;

  @override
  void initState() {
    super.initState();
    getPosts();
    getUsersPost();
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

  Future<void> getUsersPost() async {
    setState(() {
      isLoading = true;
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
            Navigator.pop(context); // Close the action sheet
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
            return _buildUserPost(
              post['title'] ?? 'No Title',
              post['description'] ?? 'No Description',
              post['timeAgo'] ?? 'Some time ago',
              post['tags'] ?? 'No tags',
              'https://example.com/user_avatar.jpg',
              'https://example.com/sample_image.jpg',
            );
          }),
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
              child: const Icon(Icons.edit, color: Color(0xFF1BBC9B)),
            ),
            GestureDetector(
              onTap: () {
                getPosts(); // Fetch all posts on refresh
              },
              child: const Icon(Icons.refresh, color: Color(0xFF1BBC9B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPost(String title, String description, String timeAgo,
      String tags, String profileImageUrl, String postImageUrl) {
    const String placeholderImage = 'assets/image (6).png';

    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;

    final String validPostImageUrl =
        postImageUrl.isNotEmpty ? postImageUrl : placeholderImage;

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
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(validProfileImageUrl),
                  child: ClipOval(
                    child: Image.network(
                      validProfileImageUrl,
                      width: 40.0,
                      height: 40.0,
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
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      tags,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 10.0),
                const Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                validPostImageUrl,
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    placeholderImage,
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
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
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BBC9B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text('Add Suggestions'),
                ),
              ],
            ),
          ],
        ),
      ),
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
