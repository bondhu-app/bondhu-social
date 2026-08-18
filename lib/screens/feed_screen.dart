import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/video_post_card.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

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
        actions: [
          IconButton(
            tooltip: 'Create Post',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Feed loading failed.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.dynamic_feed,
                    size: 70,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'এখনো কোনো Post নেই।',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Post'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 20,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index].data();
                final postId = posts[index].id;

                final type = post['type'] ?? 'text';

                if (type == 'video') {
                  return VideoPostCard(
                    videoUrl: post['videoUrl'] ?? '',
                    userName: post['userName'] ?? 'Bondhu User',
                    userPhotoUrl:
                        post['userPhotoUrl'] ?? '',
                    caption: post['text'] ?? '',
                  );
                }

                return _TextPostCard(
                  key: ValueKey(postId),
                  postId: postId,
                  userId: post['userId'] ?? '',
                  userName: post['userName'] ?? 'Bondhu User',
                  userPhotoUrl:
                      post['userPhotoUrl'] ?? '',
                  text: post['text'] ?? '',
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Post',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TextPostCard extends StatefulWidget {
  final String postId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String text;

  const _TextPostCard({
    super.key,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.text,
  });

  @override
  State<_TextPostCard> createState() => _TextPostCardState();
}

class _TextPostCardState extends State<_TextPostCard> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLiking = false;

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  Future<void> _toggleLike() async {
    final uid = currentUserId;

    if (uid == null) {
      _showLoginMessage();
      return;
    }

    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final postRef =
          _firestore.collection('posts').doc(widget.postId);

      final likeRef =
          postRef.collection('likes').doc(uid);

      final likeSnapshot = await likeRef.get();

      if (likeSnapshot.exists) {
        await likeRef.delete();

        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await likeRef.set({
          'userId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Like করা যায়নি: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  void _showLoginMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Like করতে আগে Login করুন।',
        ),
      ),
    );
  }

  void _openComments() {
    final uid = currentUserId;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Comment করতে আগে Login করুন।',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentScreen(
          postId: widget.postId,
        ),
      ),
    );
  }

  Future<void> _sharePost() async {
    final uid = currentUserId;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Share করতে আগে Login করুন।',
          ),
        ),
      );
      return;
    }

    try {
      final postRef =
          _firestore.collection('posts').doc(widget.postId);

      final shareRef =
          postRef.collection('shares').doc(uid);

      final shareSnapshot = await shareRef.get();

      if (shareSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'আপনি এই পোস্টটি ইতিমধ্যে Share করেছেন।',
            ),
          ),
        );
        return;
      }

      await shareRef.set({
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'shareCount': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Post Share হয়েছে।',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Share করা যায়নি: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUserId;

    final postRef =
        _firestore.collection('posts').doc(widget.postId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: postRef.snapshots(),
      builder: (context, postSnapshot) {
        final data = postSnapshot.data?.data() ?? {};

        final likeCount =
            (data['likeCount'] ?? 0) as num;

        final commentCount =
            (data['commentCount'] ?? 0) as num;

        final shareCount =
            (data['shareCount'] ?? 0) as num;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: uid == null
              ? null
              : postRef.collection('likes').doc(uid).snapshots(),
          builder: (context, likeSnapshot) {
            final isLiked =
                likeSnapshot.data?.exists ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          widget.userPhotoUrl.isNotEmpty
                              ? NetworkImage(
                                  widget.userPhotoUrl,
                                )
                              : null,
                      child: widget.userPhotoUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      widget.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      15,
                    ),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Text('$likeCount Likes'),
                        const SizedBox(width: 15),
                        Text('$commentCount Comments'),
                        const SizedBox(width: 15),
                        Text('$shareCount Shares'),
                      ],
                    ),
                  ),

                  const Divider(),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed:
                              _isLiking ? null : _toggleLike,
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(
                            isLiked ? 'Liked' : 'Like',
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextButton.icon(
                          onPressed: _openComments,
                          icon: const Icon(
                            Icons.comment_outlined,
                          ),
                          label: const Text('Comment'),
                        ),
                      ),

                      Expanded(
                        child: TextButton.icon(
                          onPressed: _sharePost,
                          icon: const Icon(
                            Icons.share_outlined,
                          ),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentScreen> createState() =>
      _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _sending = false;

  Future<void> _sendComment() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _sending = true;
    });

    try {
      final postRef =
          _firestore.collection('posts').doc(widget.postId);

      await postRef.collection('comments').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Bondhu User',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'commentCount': FieldValue.increment(1),
      });

      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Comment করা যায়নি: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsStream = _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: commentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Comments loading failed.\n\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final comments =
                    snapshot.data?.docs ?? [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'এখনো কোনো Comment নেই।',
                    ),
                  );
                }

                return ListView.builder(
                  reverse: false,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data();

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        comment['userName'] ??
                            'Bondhu User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        comment['text'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        if (!_sending) {
                          _sendComment();
                        }
                      },
                      decoration: const InputDecoration(
                        hintText:
                            'Comment লিখুন...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        _sending ? null : _sendComment,
                    icon: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
