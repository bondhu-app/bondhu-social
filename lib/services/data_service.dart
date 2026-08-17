import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // =========================
  // CREATE USER PROFILE
  // =========================
  Future<void> createUserProfile({
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(_userId).set({
      'name': name.trim(),
      'email': email.trim(),
      'bio': '',
      'photoUrl': '',
      'coverPhotoUrl': '',
      'friendsCount': 0,
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // =========================
  // GET CURRENT USER PROFILE
  // =========================
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots();
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile({
    required String name,
    required String bio,
  }) async {
    await _firestore.collection('users').doc(_userId).update({
      'name': name.trim(),
      'bio': bio.trim(),
    });
  }

  // =========================
  // UPDATE PROFILE PHOTO
  // =========================
  Future<void> updateProfilePhoto(String photoUrl) async {
    await _firestore.collection('users').doc(_userId).update({
      'photoUrl': photoUrl,
    });
  }

  // =========================
  // UPDATE COVER PHOTO
  // =========================
  Future<void> updateCoverPhoto(String coverPhotoUrl) async {
    await _firestore.collection('users').doc(_userId).update({
      'coverPhotoUrl': coverPhotoUrl,
    });
  }
}
