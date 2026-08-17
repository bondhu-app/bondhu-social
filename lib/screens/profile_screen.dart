import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataService _dataService = DataService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  bool _uploadingProfile = false;
  bool _uploadingCover = false;

  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile == null) return;

    setState(() {
      _uploadingProfile = true;
    });

    try {
      final file = File(pickedFile.path);

      final photoUrl =
          await _storageService.uploadProfilePhoto(file);

      await _dataService.updateProfilePhoto(photoUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile photo upload failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingProfile = false;
        });
      }
    }
  }

  Future<void> _pickCoverPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );

    if (pickedFile == null) return;

    setState(() {
      _uploadingCover = true;
    });

    try {
      final file = File(pickedFile.path);

      final coverUrl =
          await _storageService.uploadCoverPhoto(file);

      await _dataService.updateCoverPhoto(coverUrl);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cover photo updated successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cover photo upload failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingCover = false;
        });
      }
    }
  }

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
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
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
                        prefixIcon:
                            Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText:
                            'আপনার সম্পর্কে কিছু লিখুন',
                        prefixIcon:
                            Icon(Icons.info_outline),
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
                                if (nameController.text
                                    .trim()
                                    .isEmpty) {
                                  return;
                                }

                                setState(() {
                                  isSaving = true;
                                });

                                try {
                                  await _dataService
                                      .updateProfile(
                                    name:
                                        nameController.text,
                                    bio:
                                        bioController.text,
                                  );

                                  if (!sheetContext.mounted) {
                                    return;
                                  }

                                  Navigator.pop(sheetContext);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profile updated successfully.',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!sheetContext.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
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
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: _dataService.getUserProfile(),
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
                  'Profile loading failed.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final name = data['name'] ?? 'Bondhu User';
          final email = data['email'] ?? '';
          final bio = data['bio'] ?? '';
          final photoUrl = data['photoUrl'] ?? '';
          final coverPhotoUrl =
              data['coverPhotoUrl'] ?? '';

          final friendsCount =
              data['friendsCount'] ?? 0;
          final followersCount =
              data['followersCount'] ?? 0;
          final followingCount =
              data['followingCount'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // =========================
                // COVER PHOTO
                // =========================
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      coverPhotoUrl.toString().isNotEmpty
                          ? Image.network(
                              coverPhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) {
                                return _coverPlaceholder();
                              },
                            )
                          : _coverPlaceholder(),

                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Change cover photo',
                            onPressed: _uploadingCover
                                ? null
                                : _pickCoverPhoto,
                            icon: _uploadingCover
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // PROFILE AREA
                // =========================
                Transform.translate(
                  offset: const Offset(0, -55),
                  child: Column(
                    children: [
                      // PROFILE PHOTO
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                width: 4,
                                color: Colors.white,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: photoUrl
                                      .toString()
                                      .isNotEmpty
                                  ? Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) {
                                        return const Icon(
                                          Icons.person,
                                          size: 75,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 75,
                                    ),
                            ),
                          ),

                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              shape:
                                  const CircleBorder(),
                              child: IconButton(
                                tooltip:
                                    'Change profile photo',
                                onPressed:
                                    _uploadingProfile
                                        ? null
                                        : _pickProfilePhoto,
                                icon: _uploadingProfile
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // NAME
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // EMAIL
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // BIO
                      if (bio.toString().isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
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

                      // EDIT PROFILE
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showEditProfile(
                                context,
                                data,
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Edit Profile',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // STATS
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
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
                                  value:
                                      '$friendsCount',
                                ),
                                _StatItem(
                                  title: 'Followers',
                                  value:
                                      '$followersCount',
                                ),
                                _StatItem(
                                  title: 'Following',
                                  value:
                                      '$followingCount',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // MENU
                      _ProfileMenuItem(
                        icon: Icons.article_outlined,
                        title: 'My Posts',
                        onTap: () {},
                      ),

                      _ProfileMenuItem(
                        icon:
                            Icons.photo_library_outlined,
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

  Widget _coverPlaceholder() {
    return Container(
      color: Colors.blueGrey,
      child: const Center(
        child: Icon(
          Icons.photo_camera,
          size: 55,
          color: Colors.white,
        ),
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
