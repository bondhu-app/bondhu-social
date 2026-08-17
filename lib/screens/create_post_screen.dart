import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState
    extends State<CreatePostScreen> {
  final TextEditingController _textController =
      TextEditingController();

  bool _isPosting = false;

  Future<void> _createPost() async {
    final text = _textController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('আগে Login করুন।');
      return;
    }

    if (text.isEmpty) {
      _showMessage('Post-এর জন্য কিছু লিখুন।');
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance
          .collection('posts')
          .add({
        'userId': user.uid,
        'userName': userData['name'] ??
            user.displayName ??
            'Bondhu User',
        'userPhotoUrl':
            userData['photoUrl'] ?? '',
        'text': text,
        'type': 'text',
        'likes': <String>[],
        'commentsCount': 0,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _textController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Post সফলভাবে প্রকাশ হয়েছে।',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage(
        'Post করা যায়নি:\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: ElevatedButton(
              onPressed:
                  _isPosting ? null : _createPost,
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Create a post',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical:
                    TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText:
                      'আপনার মনে কী আছে?',
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMessage(
                        'Image upload পরে যোগ করা হবে।',
                      );
                    },
                    icon: const Icon(
                      Icons.photo,
                    ),
                    label: const Text(
                      'Photo',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMessage(
                        'Video upload Storage চালু হলে যোগ করা হবে।',
                      );
                    },
                    icon: const Icon(
                      Icons.video_library,
                    ),
                    label: const Text(
                      'Video',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
