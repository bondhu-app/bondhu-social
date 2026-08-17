import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/video_post_card.dart';
import 'create_post_screen.dart';
import 'create_video_post_screen.dart';

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
                  builder: (_) =>
                      const CreatePostScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.add_box_outlined,
            ),
          ),
        ],
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
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
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Feed loading failed.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final posts =
              snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
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
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CreatePostScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      'Create Post',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(
                  milliseconds: 500,
                ),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 20,
              ),
              itemCount: posts.length,
              itemBuilder: (
                context,
                index,
              ) {
                final post =
                    posts[index].data();

                final type =
                    post['type'] ?? 'text';

                if (type == 'video') {
                  return VideoPostCard(
                    videoUrl:
                        post['videoUrl'] ?? '',
                    userName:
                        post['userName'] ??
                            'Bondhu User',
                    userPhotoUrl:
                        post['userPhotoUrl'] ??
                            '',
                    caption:
                        post['text'] ?? '',
                  );
                }

                return _TextPostCard(
                  postId: posts[index].id,
                  userId:
                      post['userId'] ?? '',
                  userName:
                      post['userName'] ??
                          'Bondhu User',
                  userPhotoUrl:
                      post['userPhotoUrl'] ??
                          '',
                  text:
                      post['text'] ?? '',
                  likes:
                      List<String>.from(
                    post['likes'] ?? [],
                  ),
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
              builder: (_) =>
                  const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
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
  final List<String> likes;

  const _TextPostCard({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.text,
    required this.likes,
  });

  @override
  State<_TextPostCard> createState() =>
      _TextPostCardState();
}

class _TextPostCardState
    extends State<_TextPostCard> {
  bool _isLiking = false;

  Future<void> _toggleLike() async {
    if (_isLiking) return;

    final user =
        FirebaseFirestore.instance;

    final currentUserId =
        widget.userId.isNotEmpty
            ? widget.userId
            : '';

    final authUserId =
        currentUserId.isNotEmpty
            ? currentUserId
            : '';

    if (authUserId.isEmpty) {
      return;
    }

    setState(() {
      _isLiking = true;
    });

    try {
      final postRef = user
          .collection('posts')
          .doc(widget.postId);

      final postSnapshot =
          await postRef.get();

      final data =
          postSnapshot.data() ?? {};

      final likes =
          List<String>.from(
        data['likes'] ?? [],
      );

      if (likes.contains(authUserId)) {
        likes.remove(authUserId);
      } else {
        likes.add(authUserId);
      }

      await postRef.update({
        'likes': likes,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    final likeCount =
        widget.likes.length;

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
                  widget.userPhotoUrl
                          .isNotEmpty
                      ? NetworkImage(
                          widget.userPhotoUrl,
                        )
                      : null,
              child:
                  widget.userPhotoUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                        )
                      : null,
            ),
            title: Text(
              widget.userName,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
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
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              '$likeCount Likes',
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),

          const Divider(),

          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _isLiking
                      ? null
                      : _toggleLike,
                  icon: Icon(
                    widget.likes
                            .contains(
                          widget.userId,
                        )
                        ? Icons.favorite
                        : Icons
                            .favorite_border,
                  ),
                  label:
                      const Text('Like'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
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
                  onPressed: () {},
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
  }
}
