import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _commentController =
      TextEditingController();

  bool _isSending = false;

  CollectionReference<Map<String, dynamic>>
      get _commentsRef => FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments');

  Future<void> _sendComment() async {
    final text =
        _commentController.text.trim();

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('আগে Login করুন।');
      return;
    }

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData =
          userDoc.data() ?? {};

      await _commentsRef.add({
        'userId': user.uid,
        'userName': userData['name'] ??
            user.displayName ??
            'Bondhu User',
        'userPhotoUrl':
            userData['photoUrl'] ?? '',
        'text': text,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'commentsCount':
            FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      _showMessage(
        'Comment করা যায়নি:\n$e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
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
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String, dynamic>>>(
              stream: _commentsRef
                  .orderBy(
                    'createdAt',
                    descending: false,
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        'Comments loading failed.\n\n'
                        '${snapshot.error}',
                        textAlign:
                            TextAlign.center,
                      ),
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
                          size: 60,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'এখনো কোনো Comment নেই।',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'প্রথম Comment করুন।',
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(10),
                  itemCount: comments.length,
                  itemBuilder:
                      (context, index) {
                    final data =
                        comments[index]
                            .data();

                    final name =
                        data['userName'] ??
                            'Bondhu User';

                    final photoUrl =
                        data['userPhotoUrl'] ??
                            '';

                    final text =
                        data['text'] ?? '';

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                photoUrl
                                        .toString()
                                        .isNotEmpty
                                    ? NetworkImage(
                                        photoUrl
                                            .toString(),
                                      )
                                    : null,
                            child: photoUrl
                                    .toString()
                                    .isEmpty
                                ? const Icon(
                                    Icons.person,
                                  )
                                : null,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
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
                                  15,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    name.toString(),
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    text.toString(),
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
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                5,
                10,
                10,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _commentController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction:
                          TextInputAction.newline,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Comment লিখুন...',
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  CircleAvatar(
                    radius: 24,
                    child: IconButton(
                      onPressed: _isSending
                          ? null
                          : _sendComment,
                      icon: _isSending
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
  }
}
