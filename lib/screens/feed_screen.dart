import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _postController =
      TextEditingController();

  bool _posting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    final text = _postController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _posting = true;
    });

    try {
      await _postService.createPost(
        text: text,
      );

      _postController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _posting = false;
        });
      }
    }
  }

  Future<void> _deletePost(
    String postId,
  ) async {
    try {
      await _postService.deletePost(postId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
        ),
      );
    }
  }

  void _confirmDelete(
    String postId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'আপনি কি এই পোস্টটি মুছে ফেলতে চান?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('না'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deletePost(postId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleLike(
    String postId,
    List<dynamic> likes,
  ) async {
    try {
      await _postService.toggleLike(
        postId,
        likes,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Like failed: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bondhu Social',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Feed loading failed.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final posts = snapshot.data?.docs ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 30,
              ),
              children: [
                _buildCreatePostBox(),

                const SizedBox(height: 8),

                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 70,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'এখনো কোনো Post নেই।',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'প্রথম Post টি আপনিই করুন!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                ...posts.map(
                  (post) => _buildPostCard(
                    post.id,
                    post.data(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatePostBox() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    _auth.currentUser?.email
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'U',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller: _postController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText:
                          'আপনার মনে কী চলছে?',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed:
                    _posting ? null : _createPost,
                icon: _posting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _posting
                      ? 'Publishing...'
                      : 'Post',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(
    String postId,
    Map<String, dynamic> data,
  ) {
    final userId = data['userId'] ?? '';
    final userName =
        data['userName'] ?? 'Bondhu User';
    final userPhotoUrl =
        data['userPhotoUrl'] ?? '';
    final text = data['text'] ?? '';

    final likes =
        (data['likes'] as List?) ?? [];

    final isLiked = likes.contains(
      _auth.currentUser?.uid,
    );

    final canDelete =
        userId == _auth.currentUser?.uid;

    Timestamp? timestamp;

    if (data['createdAt'] is Timestamp) {
      timestamp = data['createdAt'] as Timestamp;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // USER HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      userPhotoUrl.toString().isNotEmpty
                          ? NetworkImage(
                              userPhotoUrl,
                            )
                          : null,
                  child:
                      userPhotoUrl.toString().isEmpty
                          ? const Icon(
                              Icons.person,
                            )
                          : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        timestamp == null
                            ? 'Just now'
                            : _formatTime(
                                timestamp.toDate(),
                              ),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (canDelete)
                  IconButton(
                    onPressed: () {
                      _confirmDelete(postId);
                    },
                    icon: const Icon(
                      Icons.more_vert,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            // POST TEXT
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(),

            // LIKE + COMMENT
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      _toggleLike(
                        postId,
                        likes,
                      );
                    },
                    icon: Icon(
                      isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: Text(
                      '${likes.length} Like',
                    ),
                  ),
                ),

                Expanded(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                    label: Text(
                      '${data['commentsCount'] ?? 0} Comment',
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

  String _formatTime(DateTime time) {
    final difference =
        DateTime.now().difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }
}
