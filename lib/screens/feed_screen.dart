import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'create_post_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Bondhu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(),
                ),
              );
            },
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
              child: ElevatedButton.icon(
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
                bottom: 90,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  postId: posts[index].id,
                  data: posts[index].data(),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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

class PostCard extends StatefulWidget {
  final String postId;
  final Map<String, dynamic> data;

  const PostCard({
    super.key,
    required this.postId,
    required this.data,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool _loadingLike = false;
  bool _loadingShare = false;

  User? get user => _auth.currentUser;

  Future<void> _toggleLike() async {
    final currentUser = user;

    if (currentUser == null) {
      _message('Like করতে আগে Login করুন।');
      return;
    }

    if (_loadingLike) return;

    setState(() {
      _loadingLike = true;
    });

    try {
      final postRef =
          _firestore.collection('posts').doc(widget.postId);

      final likeRef =
          postRef.collection('likes').doc(currentUser.uid);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();

        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await likeRef.set({
          'userId': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      _message('Like করা যায়নি।');
    } finally {
      if (mounted) {
        setState(() {
          _loadingLike = false;
        });
      }
    }
  }

  Future<void> _sharePost() async {
    final currentUser = user;

    if (currentUser == null) {
      _message('Share করতে আগে Login করুন।');
      return;
    }

    if (_loadingShare) return;

    setState(() {
      _loadingShare = true;
    });

    try {
      final postRef =
          _firestore.collection('posts').doc(widget.postId);

      final shareRef =
          postRef.collection('shares').doc(currentUser.uid);

      final shareDoc = await shareRef.get();

      if (shareDoc.exists) {
        _message('আপনি এই Post ইতিমধ্যে Share করেছেন।');
        return;
      }

      await shareRef.set({
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'shareCount': FieldValue.increment(1),
      });

      _message('Post Share হয়েছে।');
    } catch (e) {
      _message('Share করা যায়নি।');
    } finally {
      if (mounted) {
        setState(() {
          _loadingShare = false;
        });
      }
    }
  }

  void _openComments() {
    if (user == null) {
      _message('Comment করতে আগে Login করুন।');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(
          postId: widget.postId,
        ),
      ),
    );
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postRef =
        _firestore.collection('posts').doc(widget.postId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: postRef.snapshots(),
      builder: (context, postSnapshot) {
        final data =
            postSnapshot.data?.data() ?? widget.data;

        final String userName =
            data['userName'] ?? 'Bondhu User';

        final String photoUrl =
            data['userPhotoUrl'] ?? '';

        final String text =
            data['text'] ?? '';

        final int likeCount =
            (data['likeCount'] ?? 0) as num;

        final int commentCount =
            (data['commentCount'] ?? 0) as num;

        final int shareCount =
            (data['shareCount'] ?? 0) as num;

        return StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null
              ? null
              : postRef
                  .collection('likes')
                  .doc(user!.uid)
                  .snapshots(),
          builder: (context, likeSnapshot) {
            final isLiked =
                likeSnapshot.data?.exists ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              elevation: 0,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage:
                          photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        const Text('Public'),
                    trailing: const Icon(
                      Icons.more_horiz,
                    ),
                  ),

                  if (text.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        14,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        if (likeCount > 0)
                          const Icon(
                            Icons.favorite,
                            size: 18,
                          ),
                        const SizedBox(width: 5),
                        Text('$likeCount'),

                        const Spacer(),

                        Text(
                          '$commentCount Comments',
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$shareCount Shares',
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed:
                              _loadingLike
                                  ? null
                                  : _toggleLike,
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons
                                    .favorite_border,
                          ),
                          label: Text(
                            isLiked
                                ? 'Liked'
                                : 'Like',
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextButton.icon(
                          onPressed:
                              _openComments,
                          icon: const Icon(
                            Icons
                                .comment_outlined,
                          ),
                          label: const Text(
                            'Comment',
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextButton.icon(
                          onPressed:
                              _loadingShare
                                  ? null
                                  : _sharePost,
                          icon: const Icon(
                            Icons.share_outlined,
                          ),
                          label: const Text(
                            'Share',
                          ),
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

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsScreen> createState() =>
      _CommentsScreenState();
}

class _CommentsScreenState
    extends State<CommentsScreen> {
  final TextEditingController _controller =
      TextEditingController();

  bool _sending = false;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> _sendComment() async {
    final currentUser =
        _auth.currentUser;

    if (currentUser == null) return;

    final text =
        _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _sending = true;
    });

    try {
      final postRef =
          _firestore
              .collection('posts')
              .doc(widget.postId);

      final commentRef =
          postRef.collection('comments').doc();

      await commentRef.set({
        'userId': currentUser.uid,
        'userName':
            currentUser.displayName ??
                'Bondhu User',
        'text': text,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'commentCount':
            FieldValue.increment(1),
      });

      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Comment করা যায়নি।'),
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
    final commentsStream =
        _firestore
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
        title:
            const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: commentsStream,
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Comments loading failed.\n\n${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                  );
                }

                final comments =
                    snapshot.data?.docs ??
                        [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'এখনো কোনো Comment নেই।',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                      comments.length,
                  itemBuilder:
                      (context, index) {
                    final data =
                        comments[index]
                            .data();

                    return ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        data['userName'] ??
                            'Bondhu User',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        data['text'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _controller,
                      textInputAction:
                          TextInputAction
                              .send,
                      onSubmitted: (_) {
                        if (!_sending) {
                          _sendComment();
                        }
                      },
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Write a comment...',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed:
                        _sending
                            ? null
                            : _sendComment,
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
