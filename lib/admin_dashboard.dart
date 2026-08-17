import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  int selectedIndex = 0;

  Future<int> getCount(String collection) async {
    try {
      final snapshot =
          await _firestore.collection(collection).get();

      return snapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Widget statCard({
    required String title,
    required IconData icon,
    required Future<int> count,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            FutureBuilder<int>(
              future: count,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }

                return Text(
                  '${snapshot.data ?? 0}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Welcome Admin',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            statCard(
              title: 'Users',
              icon: Icons.people,
              count: getCount('users'),
            ),

            statCard(
              title: 'Posts',
              icon: Icons.article,
              count: getCount('posts'),
            ),

            statCard(
              title: 'Comments',
              icon: Icons.comment,
              count: getCount('comments'),
            ),

            statCard(
              title: 'Reports',
              icon: Icons.flag,
              count: getCount('reports'),
            ),
          ],
        ),

        const SizedBox(height: 25),

        const Text(
          'Management',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        managementCard(
          icon: Icons.people,
          title: 'Manage Users',
          subtitle: 'View and manage users',
          index: 1,
        ),

        managementCard(
          icon: Icons.article,
          title: 'Manage Posts',
          subtitle: 'View and manage posts',
          index: 2,
        ),

        managementCard(
          icon: Icons.comment,
          title: 'Manage Comments',
          subtitle: 'View and manage comments',
          index: 3,
        ),

        managementCard(
          icon: Icons.flag,
          title: 'Reports',
          subtitle: 'Review reported content',
          index: 4,
        ),
      ],
    );
  }

  Widget managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget collectionPage({
    required String title,
    required String collection,
    required IconData icon,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading $title',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 70,
                  color: Colors.grey,
                ),
                const SizedBox(height: 15),
                Text(
                  'No $title found',
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            final data =
                doc.data()
                    as Map<String, dynamic>;

            final name =
                data['name'] ??
                data['displayName'] ??
                data['username'] ??
                'Unknown';

            final email =
                data['email'] ?? '';

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(icon),
                ),
                title: Text(
                  name.toString(),
                ),
                subtitle: Text(
                  email.toString().isEmpty
                      ? 'ID: ${doc.id}'
                      : email.toString(),
                ),
                trailing:
                    PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      deleteDocument(
                        collection,
                        doc.id,
                      );
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deleteDocument(
    String collection,
    String id,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Delete'),
          content: const Text(
            'Are you sure you want to delete this item?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('Delete failed: $e'),
        ),
      );
    }
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: ListTile(
            leading: const Icon(
              Icons.admin_panel_settings,
            ),
            title:
                const Text('Admin Account'),
            subtitle: Text(
              _auth.currentUser?.email ??
                  'Admin',
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading:
                const Icon(Icons.logout),
            title:
                const Text('Logout'),
            onTap: logout,
          ),
        ),
      ],
    );
  }

  Widget currentPage() {
    switch (selectedIndex) {
      case 1:
        return collectionPage(
          title: 'Users',
          collection: 'users',
          icon: Icons.people,
        );

      case 2:
        return collectionPage(
          title: 'Posts',
          collection: 'posts',
          icon: Icons.article,
        );

      case 3:
        return collectionPage(
          title: 'Comments',
          collection: 'comments',
          icon: Icons.comment,
        );

      case 4:
        return collectionPage(
          title: 'Reports',
          collection: 'reports',
          icon: Icons.flag,
        );

      case 5:
        return settingsPage();

      default:
        return dashboardPage();
    }
  }

  String pageTitle() {
    switch (selectedIndex) {
      case 1:
        return 'Users';

      case 2:
        return 'Posts';

      case 3:
        return 'Comments';

      case 4:
        return 'Reports';

      case 5:
        return 'Settings';

      default:
        return 'Admin Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle()),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName:
                    const Text('Admin'),
                accountEmail: Text(
                  _auth.currentUser?.email ??
                      'Admin Account',
                ),
                currentAccountPicture:
                    const CircleAvatar(
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 35,
                  ),
                ),
              ),

              drawerItem(
                Icons.dashboard,
                'Dashboard',
                0,
              ),

              drawerItem(
                Icons.people,
                'Users',
                1,
              ),

              drawerItem(
                Icons.article,
                'Posts',
                2,
              ),

              drawerItem(
                Icons.comment,
                'Comments',
                3,
              ),

              drawerItem(
                Icons.flag,
                'Reports',
                4,
              ),

              drawerItem(
                Icons.settings,
                'Settings',
                5,
              ),

              const Spacer(),

              ListTile(
                leading:
                    const Icon(Icons.logout),
                title:
                    const Text('Logout'),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),

      body: currentPage(),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            selectedIndex > 4
                ? 0
                : selectedIndex,

        onDestinationSelected:
            (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            selectedIcon: Icon(
              Icons.dashboard,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.people_outline,
            ),
            selectedIcon: Icon(
              Icons.people,
            ),
            label: 'Users',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.article_outlined,
            ),
            selectedIcon: Icon(
              Icons.article,
            ),
            label: 'Posts',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.comment_outlined,
            ),
            selectedIcon: Icon(
              Icons.comment,
            ),
            label: 'Comments',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.flag_outlined,
            ),
            selectedIcon: Icon(
              Icons.flag,
            ),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget drawerItem(
    IconData icon,
    String title,
    int index,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected:
          selectedIndex == index,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });

        Navigator.pop(context);
      },
    );
  }
}
