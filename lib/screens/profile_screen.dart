import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/data_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();

  void _showEditProfile(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final nameController = TextEditingController(
      text: data['name'] ?? '',
    );

    final bioController = TextEditingController(
      text: data['bio'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'নাম',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'আপনার সম্পর্কে কিছু লিখুন',
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (nameController.text.trim().isEmpty) {
                                return;
                              }

                              setState(() {
                                isSaving = true;
                              });

                              try {
                                await _dataService.updateProfile(
                                  name: nameController.text,
                                  bio: bioController.text,
                                );

                                if (!sheetContext.mounted) return;

                                Navigator.pop(sheetContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile updated successfully.',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!sheetContext.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Update failed: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _authService.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _dataService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Profile loading failed.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final name = data['name'] ?? 'Bondhu User';
          final email = data['email'] ?? '';
          final bio = data['bio'] ?? '';
          final photoUrl = data['photoUrl'] ?? '';
          final coverPhotoUrl = data['coverPhotoUrl'] ?? '';

          final friendsCount = data['friendsCount'] ?? 0;
          final followersCount = data['followersCount'] ?? 0;
          final followingCount = data['followingCount'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // =========================
                // COVER PHOTO
                // =========================
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: coverPhotoUrl.toString().isNotEmpty
                      ? Image.network(
                          coverPhotoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.blueGrey,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.blueGrey,
                          child: const Center(
                            child: Icon(
                              Icons.photo_camera,
                              size: 55,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                // =========================
                // PROFILE PHOTO
                // =========================
                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            width: 4,
                            color: Colors.white,
                          ),
                        ),
                        child: ClipOval(
                          child: photoUrl.toString().isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Icon(
                                      Icons.person,
                                      size: 70,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 70,
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // NAME
                      // =========================
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // =========================
                      // EMAIL
                      // =========================
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // BIO
                      // =========================
                      if (bio.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // =========================
                      // EDIT PROFILE
                      // =========================
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showEditProfile(context, data);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Edit Profile',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // PROFILE STATS
                      // =========================
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  title: 'Posts',
                                  value: '0',
                                ),
                                _StatItem(
                                  title: 'Friends',
                                  value: '$friendsCount',
                                ),
                                _StatItem(
                                  title: 'Followers',
                                  value: '$followersCount',
                                ),
                                _StatItem(
                                  title: 'Following',
                                  value: '$followingCount',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================
                      // PROFILE MENU
                      // =========================
                      _ProfileMenuItem(
                        icon: Icons.article_outlined,
                        title: 'My Posts',
                        onTap: () {},
                      ),

                      _ProfileMenuItem(
                        icon: Icons.photo_library_outlined,
                        title: 'Photos',
                        onTap: () {},
                      ),

                      _ProfileMenuItem(
                        icon: Icons.people_outline,
                        title: 'Friends',
                        onTap: () {},
                      ),

                      _ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {},
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({
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
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: onTap,
    );
  }
}
