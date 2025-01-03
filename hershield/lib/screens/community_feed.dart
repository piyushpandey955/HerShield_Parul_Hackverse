import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CommunityFeed extends StatefulWidget {
  const CommunityFeed({super.key});

  @override
  State<CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<CommunityFeed> {
  final DatabaseReference _postsRef =
      FirebaseDatabase.instance.ref().child('posts');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? _selectedImage; // For image upload
  String _postText = ""; // Text content of the post
  final TextEditingController _commentController = TextEditingController();

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Submit a post (text, image, or both)
  Future<void> _submitPost() async {
    if (_postText.isNotEmpty || _selectedImage != null) {
      String? userId = _auth.currentUser?.uid;

      // Fetch user details
      final userSnapshot = await _usersRef.child(userId!).get();
      final userData = userSnapshot.value as Map;

      final newPostRef = _postsRef.push();
      final postData = {
        'userId': userId,
        'userName': userData['name'] ?? 'Anonymous',
        'userAvatar': userData['avatarUrl'] ?? '',
        'postText': _postText,
        'imagePath': _selectedImage?.path ?? '',
        'upvotes': 0,
        'downvotes': 0,
        'comments': [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      await newPostRef.set(postData);

      // Clear fields
      setState(() {
        _selectedImage = null;
        _postText = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text or add an image.')),
      );
    }
  }

  // Upvote a post
  Future<void> _upvotePost(String postId, int currentUpvotes) async {
    final postRef = _postsRef.child(postId);
    await postRef.update({'upvotes': currentUpvotes + 1});
  }

  // Downvote a post
  Future<void> _downvotePost(String postId, int currentDownvotes) async {
    final postRef = _postsRef.child(postId);
    await postRef.update({'downvotes': currentDownvotes + 1});
  }

  // Add a comment to a post
  Future<void> _addComment(String postId, String comment) async {
    final commentsRef = _postsRef.child(postId).child('comments');
    await commentsRef.push().set({
      'userId': _auth.currentUser?.uid,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Feed"),
      ),
      body: Column(
        children: [
          // Post submission area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _postText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "What's on your mind?",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _pickImage,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _submitPost,
                      child: const Text("Post"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Feed display
          Expanded(
            child: StreamBuilder(
              stream: _postsRef.orderByChild('timestamp').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final postsMap = snapshot.data!.snapshot.value as Map;
                  final posts = postsMap.entries.toList()
                    ..sort((a, b) => b.value['timestamp']
                        .compareTo(a.value['timestamp']));

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final postKey = posts[index].key;
                      final post = posts[index].value;

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User details (Avatar and Name)
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: post['userAvatar'] != ''
                                    ? NetworkImage(post['userAvatar'])
                                    : null,
                                child: post['userAvatar'] == ''
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(post['userName'] ?? 'Anonymous'),
                              subtitle: Text(post['timestamp']),
                            ),
                            if (post['imagePath'] != '') // If image exists
                              Image.file(
                                File(post['imagePath']),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                post['postText'] ?? "",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.thumb_up),
                                  onPressed: () {
                                    _upvotePost(postKey, post['upvotes']);
                                  },
                                ),
                                Text("${post['upvotes']}"),
                                IconButton(
                                  icon: const Icon(Icons.thumb_down),
                                  onPressed: () {
                                    _downvotePost(postKey, post['downvotes']);
                                  },
                                ),
                                Text("${post['downvotes']}"),
                              ],
                            ),
                            ExpansionTile(
                              title: const Text("Comments"),
                              children: [
                                ...((post['comments'] ?? {}) as Map<dynamic, dynamic>)
                                    .values
                                    .map((comment) => ListTile(
                                          title: Text(comment['comment']),
                                          subtitle: Text(comment['userId']),
                                        ))
                                    ,
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      labelText: "Add a comment...",
                                    ),
                                    onSubmitted: (value) {
                                      _addComment(postKey, value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No posts available."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}