import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/friend_service.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FriendService friendService = FriendService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: friendService.getReceivedRequests(),
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
                  'Requests loading failed.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_disabled,
                    size: 70,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'কোনো Friend Request নেই।',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data();

              final senderId =
                  data['senderId'] ?? '';

              return FutureBuilder<
                  DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(senderId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(
                        leading:
                            CircularProgressIndicator(),
                        title: Text(
                          'Loading user...',
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
                      bottom: 10,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
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
                                        size: 28,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await friendService
                                          .acceptFriendRequest(
                                        request.id,
                                        senderId,
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Friend request accepted.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Accept failed: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child:
                                      const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    try {
                                      await friendService
                                          .rejectFriendRequest(
                                        request.id,
                                      );

                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Friend request rejected.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger
                                              .of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Reject failed: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child:
                                      const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
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
