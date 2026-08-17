import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/comment_service.dart';
import '../services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();
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

    if (text.isEmpty) return;

    setState(() {
      _posting = true;
    });

    try {
      await _postService.createPost(text: text);
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

  Future<void> _deletePost(String postId) async {
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

  void _confirmDelete(String postId) {
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

  void _openComments(
    String postId,
    String postOwnerName,
  ) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        bool sending = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<
                        QuerySnapshot<
                            Map<String, dynamic>>>(
                      stream: _commentService.getComments(
                        postId,
                      ),
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
                              'Comments loading failed.\n${snapshot.error}',
                              textAlign:
                                  TextAlign.center,
                            ),
                          );
                        }

                        final comments =
                            snapshot.data?.docs ?? [];

                        if (comments.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons
                                      .chat_bubble_outline,
                                  size: 55,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'এখনো কোনো Comment নেই।',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          itemCount: comments.length,
                          itemBuilder:
                              (context, index) {
                            final comment =
                                comments[index];

                            final data =
                                comment.data();

                            final userName =
                                data['userName'] ??
                                    'Bondhu User';

                            final photoUrl =
                                data['userPhotoUrl'] ??
                                    '';

                            final text =
                                data['text'] ?? '';

                            final commentUserId =
                                data['userId'] ?? '';

                            final isOwner =
                                commentUserId ==
                                    _auth.currentUser
                                        ?.uid;

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        photoUrl
                                                .toString()
                                                .isNotEmpty
                                            ? NetworkImage(
                                                photoUrl,
                                              )
                                            : null,
                                    child: photoUrl
                                            .toString()
                                            .isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding:
                                          const EdgeInsets
                                              .all(12),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .grey
                                            .shade100,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          16,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  userName,
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isOwner)
                                                PopupMenuButton(
                                                  padding:
                                                      EdgeInsets.zero,
                                                  itemBuilder:
                                                      (context) {
                                                    return const [
                                                      PopupMenuItem(
                                                        value:
                                                            'delete',
                                                        child:
                                                            Text(
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
