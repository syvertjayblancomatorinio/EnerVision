import 'package:flutter/material.dart';

class CommunityGuidelines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1BBC9B), // Setting the primary color
        scaffoldBackgroundColor: Colors.white, // White background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for large body
          bodyMedium: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for medium body
          bodySmall: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.black), // Black text for small body
        ),
      ),
      home: CommunityHomePage(),
    );
  }
}

class CommunityHomePage extends StatefulWidget {
  @override
  _CommunityHomePageState createState() => _CommunityHomePageState();
}

class _CommunityHomePageState extends State<CommunityHomePage> {
  bool _hasAcknowledged = false;
  bool _isPostingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.close), // X icon
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Community Guidelines',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat'),
            ),
            const SizedBox(height: 16.0),
            Text(
              '''Welcome to our community! Here are some guidelines you should follow when posting and interacting with others:''',
              style: Theme.of(context).textTheme.bodyMedium, // Using bodyMedium
            ),
            const SizedBox(height: 16.0),
            Text(
              '''1. Be Respectful
    • Treat everyone with kindness and respect.
    • Avoid personal attacks, insults, or inflammatory remarks.
    • Discrimination, hate speech, or harassment will not be tolerated.

2. Keep It Safe
    • Be cautious when sharing personal information.
    • Do not share highly sensitive data like passwords or financial account numbers.
    • Avoid posting harmful or illegal content.

3. Your Name and Profile Information
    • Your name and profile will be visible to others.
    • Ensure your profile information is accurate and respectful.

4. Constructive Communication
    • Engage in meaningful, constructive discussions.
    • Disagree respectfully and offer helpful insights.

5. No Spam or Self-Promotion
    • Avoid spamming the community with irrelevant links or promotional content.

6. Stay On Topic
    • Keep posts relevant to the community themes.

7. Protect Privacy
    • Do not share private messages or content without permission.

8. Report Violations
    • Help maintain the community’s quality by reporting inappropriate content.

9. Follow the Law
    • Ensure posts and interactions comply with laws.

10. Moderation
    • Moderators have the right to remove content that violates guidelines.

11. Be Kind and Helpful
    • Offer support, advice, and encouragement to fellow members.''',
              style: Theme.of(context).textTheme.bodyMedium, // Using bodyMedium
            ),
            const SizedBox(height: 24.0),
            CheckboxListTile(
              title: const Text(
                  "I acknowledge and agree to follow the Community Guidelines",
                  style: TextStyle(fontFamily: 'Montserrat')),
              value: _hasAcknowledged,
              onChanged: (bool? value) {
                setState(() {
                  _hasAcknowledged = value ?? false;
                  _isPostingEnabled = _hasAcknowledged;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF1BBC9B), // Change color when checked
              checkColor: Colors.white, // Checkmark color
              tileColor: Colors.white, // Background color remains white
            ),
            const SizedBox(height: 16.0),
            Center(
              // Centering the button
              child: ElevatedButton(
                onPressed: _isPostingEnabled
                    ? () {
                        // Add your post action here
                        print("Proceeding to post...");
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BBC9B), // Button color
                ),
                child: const Text(
                  "Continue to Post",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat'), // White text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
