import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'ইমেইল ঠিকানা সঠিক নয়।';

      case 'user-not-found':
        return 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';

      case 'wrong-password':
      case 'invalid-credential':
        return 'ইমেইল অথবা পাসওয়ার্ড ভুল।';

      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট আছে।';

      case 'weak-password':
        return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।';

      case 'user-disabled':
        return 'এই অ্যাকাউন্টটি বন্ধ করা হয়েছে।';

      case 'too-many-requests':
        return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ পরীক্ষা করুন।';

      case 'operation-not-allowed':
        return 'Email/Password Authentication চালু নেই।';

      default:
        return e.message ?? 'Authentication failed। আবার চেষ্টা করুন।';
    }
  }
}
