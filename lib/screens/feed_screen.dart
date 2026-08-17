                                                        child:
                           import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/video_post_card.dart';
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
            tooltip: 'Create Video',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateVideoPostScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.video_call,
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
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dynamic_feed,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'এখনো কোনো Post নেই।',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'প্রথম Post তৈরি করুন।',
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
              padding:
                  const EdgeInsets.only(
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
                  userName:
                      post['userName'] ??
                          'Bondhu User',
                  userPhotoUrl:
                      post['userPhotoUrl'] ??
                          '',
                  text:
                      post['text'] ?? '',
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TextPostCard extends StatelessWidget {
  final String userName;
  final String userPhotoUrl;
  final String text;

  const _TextPostCard({
    required this.userName,
    required this.userPhotoUrl,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
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
                  userPhotoUrl.isNotEmpty
                      ? NetworkImage(
                          userPhotoUrl,
                        )
                      : null,
              child: userPhotoUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              userName,
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
              12,
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          const Divider(height: 1),

          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite_border,
                  ),
                  label: const Text('Like'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  label: const Text('Comment'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
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
  }
}                                 Text(
                                                          'Delete',
                                                        ),
                                                      ),
                                                    ];
                                                  },
                                                  onSelected:
                                                      (value) async {
                                                    if (value ==
                                                        'delete') {
                                                      try {
                                                        await _commentService
                                                            .deleteComment(
                                                          postId:
                                                              postId,
                                                          commentId:
                                                              comment.id,
                                                        );
                                                      } catch (e) {
                                                        if (!context
                                                            .mounted) {
                                                          return;
                                                        }

                                                        ScaffoldMessenger
                                                                .of(
                                                                    context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content:
                                                                Text(
                                                              'Delete failed: $e',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(text),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: MediaQuery.of(context)
                                .viewInsets
                                .bottom +
                            8,
                        top: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  commentController,
                              textInputAction:
                                  TextInputAction.send,
                              onSubmitted: (_) async {
                                if (sending) return;

                                final text =
                                    commentController
                                        .text
                                        .trim();

                                if (text.isEmpty) return;

                                setSheetState(() {
                                  sending = true;
                                });

                                try {
                                  await _commentService
                                      .addComment(
                                    postId: postId,
                                    text: text,
                                  );

                                  commentController
                                      .clear();
                                } catch (e) {
                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger
                                          .of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Comment failed: $e',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (context.mounted) {
                                    setSheetState(() {
                                      sending = false;
                                    });
                                  }
                                }
                              },
                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Comment লিখুন...',
                                filled: true,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    25,
                                  ),
                                  borderSide:
                                      BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 23,
                            child: IconButton(
                              onPressed: sending
                                  ? null
                                  : () async {
                                      final text =
                                          commentController
                                              .text
                                              .trim();

                                      if (text.isEmpty) {
                                        return;
                                      }

                                      setSheetState(() {
                                        sending = true;
                                      });

                                      try {
                                        await _commentService
                                            .addComment(
                                          postId: postId,
                                          text: text,
                                        );

                                        commentController
                                            .clear();
                                      } catch (e) {
                                        if (!context
                                            .mounted) {
                                          return;
                                        }

                                        ScaffoldMessenger
                                                .of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Comment failed: $e',
                                            ),
                                          ),
                                        );
                                      } finally {
                                        if (context
                                            .mounted) {
                                          setSheetState(() {
                                            sending = false;
                                          });
                                        }
                                      }
                                    },
                              icon: sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      commentController.dispose();
    });
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
                const Duration(milliseconds: 400),
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

    final isLiked =
        likes.contains(_auth.currentUser?.uid);

    final canDelete =
        userId == _auth.currentUser?.uid;

    final commentsCount =
        data['commentsCount'] ?? 0;

    Timestamp? timestamp;

    if (data['createdAt'] is Timestamp) {
      timestamp =
          data['createdAt'] as Timestamp;
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
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      userPhotoUrl
                              .toString()
                              .isNotEmpty
                          ? NetworkImage(
                              userPhotoUrl,
                            )
                          : null,
                  child:
                      userPhotoUrl.toString().isEmpty
                          ? const Icon(Icons.person)
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
                    icon:
                        const Icon(Icons.more_vert),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(),

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
                    onPressed: () {
                      _openComments(
                        postId,
                        userName,
                      );
                    },
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                    label: Text(
                      '$commentsCount Comment',
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
