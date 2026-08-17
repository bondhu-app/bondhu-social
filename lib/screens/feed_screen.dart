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
                    'প্রথম Video Post তৈরি করুন।',
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
}
