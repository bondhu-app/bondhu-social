import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  'Feed loading failed:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text('এখনো কোনো Post নেই।'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 80,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(
                postId: posts[index].id,
                data: posts[index].data(),
              );
            },
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

class PostCard extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;

  const PostCard({
    super.key,
    required this.postId,
    required this.data,
  });

  Future<void> toggleLike(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(context, 'Like করতে আগে Login করুন।');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final postRef =
          firestore.collection('posts').doc(postId);

      final likeRef =
          postRef.collection('likes').doc(user.uid);

      final likeDoc = await likeRef.get();

      if (likeDoc.exists) {
        await likeRef.delete();

        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        await likeRef.set({
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      showMessage(
        context,
        'Like করা যায়নি:\n$e',
      );
    }
  }

  Future<void> sharePost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(context, 'Share করতে আগে Login করুন।');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      final postRef =
          firestore.collection('posts').doc(postId);

      final shareRef =
          postRef.collection('shares').doc(user.uid);

      final shareDoc = await shareRef.get();

      if (shareDoc.exists) {
        showMessage(
          context,
          'আপনি ইতিমধ্যে এই Post Share করেছেন।',
        );
        return;
      }

      await shareRef.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'shareCount': FieldValue.increment(1),
      });

      showMessage(
        context,
        'Post Share হয়েছে।',
      );
    } catch (e) {
      showMessage(
        context,
        'Share করা যায়নি:\n$e',
      );
    }
  }

  void openComments(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage(
        context,
        'Comment করতে আগে Login করুন।',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(
          postId: postId,
        ),
      ),
    );
  }

  static void showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postRef =
        FirebaseFirestore.instance
            .collection('posts')
            .doc(postId);

    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: postRef.snapshots(),
      builder: (context, snapshot) {
        final postData =
            snapshot.data?.data() ?? data;

        final String name =
            postData['userName'] ?? 'Bondhu User';

        final String photoUrl =
            postData['userPhotoUrl'] ?? '';

        final String text =
            postData['text'] ?? '';

        final int likes =
            (postData['likeCount'] ?? 0) as num;

        final int comments =
            (postData['commentCount'] ?? 0) as num;

        final int shares =
            (postData['shareCount'] ?? 0) as num;

        return StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: user == null
              ? null
              : postRef
                  .collection('likes')
                  .doc(user.uid)
                  .snapshots(),
          builder: (context, likeSnapshot) {
            final bool isLiked =
                likeSnapshot.data?.exists ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text('Public'),
                  ),

                  if (text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        15,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text('$likes Likes'),
                        const Spacer(),
                        Text('$comments Comments'),
                        const SizedBox(width: 12),
                        Text('$shares Shares'),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            toggleLike(context);
                          },
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
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
                          onPressed: () {
                            openComments(context);
                          },
                          icon: const Icon(
                            Icons.comment_outlined,
                          ),
                          label: const Text(
                            'Comment',
                          ),
                        ),
                      ),

                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            sharePost(context);
                          },
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
  final TextEditingController controller =
      TextEditingController();

  bool sending = false;

  Future<void> sendComment() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final text =
        controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      sending = true;
    });

    try {
      final firestore =
          FirebaseFirestore.instance;

      final postRef =
          firestore
              .collection('posts')
              .doc(widget.postId);

      await postRef.collection('comments').add({
        'userId': user.uid,
        'userName':
            user.displayName ?? 'Bondhu User',
        'text': text,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      await postRef.update({
        'commentCount':
            FieldValue.increment(1),
      });

      controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Comment করা যায়নি:\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream =
        FirebaseFirestore.instance
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
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error:\n${snapshot.error}',
                      textAlign:
                          TextAlign.center,
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
                  itemCount:
                      comments.length,
                  itemBuilder:
                      (context, index) {
                    final comment =
                        comments[index].data();

                    return ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        comment['userName'] ??
                            'Bondhu User',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        comment['text'] ??
                            '',
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
                      controller: controller,
                      textInputAction:
                          TextInputAction.send,
                      onSubmitted: (_) {
                        if (!sending) {
                          sendComment();
                        }
                      },
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Comment লিখুন...',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        sending
                            ? null
                            : sendComment,
                    icon: sending
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
