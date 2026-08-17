import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  final _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email এবং Password দিন।');
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showMessage('আপনার নাম দিন।');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password কমপক্ষে 6 অক্ষরের হতে হবে।');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final credential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'photoUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_authError(e.code));
    } catch (e) {
      _showMessage('সমস্যা হয়েছে: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('প্রথমে Email লিখুন।');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      );

      _showMessage(
        'Password reset link আপনার Email-এ পাঠানো হয়েছে।',
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(_authError(e.code));
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email ঠিক নয়।';
      case 'user-not-found':
        return 'এই Email-এর কোনো account নেই।';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email অথবা Password ভুল।';
      case 'email-already-in-use':
        return 'এই Email দিয়ে আগে থেকেই account আছে।';
      case 'weak-password':
        return 'Password আরও শক্তিশালী দিন।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
      default:
        return 'Authentication error: $code';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.people_alt,
                  size: 80,
                ),
                const SizedBox(height: 15),

                const Text(
                  'Bondhu Social',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (!_isLogin)
                  TextField(
                    controller: _nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'আপনার নাম',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                if (!_isLogin)
                  const SizedBox(height: 15),

                TextField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon:
                        const Icon(Icons.lock),
                    border:
                        const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        'Password Reset',
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isLogin
                                ? 'Login'
                                : 'Create Account',
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                  child: Text(
                    _isLogin
                        ? 'নতুন Account তৈরি করুন'
                        : 'আগের Account দিয়ে Login করুন',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
