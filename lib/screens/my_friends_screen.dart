import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/friend_service.dart';

class MyFriendsScreen extends StatelessWidget {
  const MyFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendService = FriendService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: friendService.getFriends(),
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
                  'Friends loading failed.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final friends = snapshot.data?.docs ?? [];

          if (friends.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'আপনার এখনো কোনো Friend নেই।',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Friends থেকে User Search করে Add Friend করুন।',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friendId =
                  friends[index].id;

              return FutureBuilder<
                  DocumentSnapshot<
                      Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading:
                            CircularProgressIndicator(),
                        title: Text(
                          'Loading...',
                        ),
                      ),
                    );
                  }

                  final userData =
                      userSnapshot.data?.data() ?? {};

                  final name =
                      userData['name'] ??
                          'Bondhu User';

                  final photoUrl =
                      userData['photoUrl'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
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
                              )
                            : null,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Friend',
                      ),
                      trailing: const Icon(
                        Icons.check_circle,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
