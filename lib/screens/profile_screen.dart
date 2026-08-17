import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final name =
              data['name'] ??
              user.displayName ??
              'Bondhu User';

          final email =
              data['email'] ??
              user.email ??
              '';

          final photoUrl =
              data['photoUrl'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      photoUrl.toString().isNotEmpty
                          ? NetworkImage(
                              photoUrl.toString(),
                            )
                          : null,
                  child:
                      photoUrl.toString().isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 60,
                            )
                          : null,
                ),

                const SizedBox(height: 15),

                Text(
                  name.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(
                      title: 'Posts',
                      value: '0',
                    ),
                    _ProfileStat(
                      title: 'Friends',
                      value: '0',
                    ),
                    _ProfileStat(
                      title: 'Likes',
                      value: '0',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                          ),
                          label: const Text(
                            'Edit Profile',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share,
                          ),
                          label: const Text(
                            'Share',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Divider(),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.post_add,
                    ),
                  ),
                  title: const Text(
                    'My Posts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.people,
                    ),
                  ),
                  title: const Text(
                    'Friends',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.bookmark,
                    ),
                  ),
                  title: const Text(
                    'Saved Posts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.logout,
                    ),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance
                        .signOut();
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
