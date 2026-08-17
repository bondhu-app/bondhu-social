import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin_dashboard.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BondhuSocialApp());
}

class BondhuSocialApp extends StatelessWidget {
  const BondhuSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Bondhu Social',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),

      home: const AuthGate(),
    );
  }
}

// =====================================================
// AUTH GATE
// =====================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isAdmin(User user) async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!document.exists) {
        return false;
      }

      final data = document.data();

      final role =
          data?['role']?.toString().toLowerCase();

      return role == 'admin';
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // =================================================
        // LOADING
        // =================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // =================================================
        // USER LOGGED OUT
        // =================================================

        if (!snapshot.hasData) {
          return const AuthScreen();
        }

        // =================================================
        // USER LOGGED IN
        // =================================================

        final user = snapshot.data!;

        return FutureBuilder<bool>(
          future: isAdmin(user),

          builder: (context, adminSnapshot) {
            // =================================================
            // CHECKING ADMIN
            // =================================================

            if (adminSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // =================================================
            // ADMIN
            // =================================================

            if (adminSnapshot.data == true) {
              return const AdminDashboard();
            }

            // =================================================
            // NORMAL USER
            // =================================================

            return const MainNavigation();
          },
        );
      },
    );
  }
}

// =====================================================
// MAIN NAVIGATION
// =====================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    FriendsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
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
            label: 'Friends',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.notifications_outlined,
            ),
            selectedIcon: Icon(
              Icons.notifications,
            ),
            label: 'Notifications',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FRIENDS SCREEN
// =====================================================

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.people,
              size: 70,
            ),

            SizedBox(height: 15),

            Text(
              'Friends',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Friend system খুব শীঘ্রই যোগ হবে।',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// NOTIFICATIONS SCREEN
// =====================================================

class NotificationsScreen
    extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.notifications,
              size: 70,
            ),

            SizedBox(height: 15),

            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'কোনো নতুন notification নেই।',
            ),
          ],
        ),
      ),
    );
  }
}
