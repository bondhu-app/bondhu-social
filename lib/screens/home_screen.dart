import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আপনি লগআউট করেছেন।'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('লগআউট'),
          content: const Text(
            'আপনি কি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('না'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
              child: const Text('হ্যাঁ, লগআউট'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bondhu Social'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_alt_rounded,
                size: 90,
              ),

              const SizedBox(height: 24),

              const Text(
                'Bondhu Social-এ স্বাগতম!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                user?.email ?? 'User',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'আপনি সফলভাবে লগইন করেছেন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person,
                  ),
                  label: const Text(
                    'আমার Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(
                    Icons.logout,
                  ),
                  label: const Text(
                    'লগআউট',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
