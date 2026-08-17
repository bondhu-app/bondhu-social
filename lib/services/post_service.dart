import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // =========================
  // CREATE POST
  // =========================

  Future<void> createPost({
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    await _firestore.collection('posts').add({
      'userId': user.uid,
      'userName': userData['name'] ?? 'Bondhu User',
      'userPhotoUrl': userData['photoUrl'] ?? '',
      'text': text.trim(),
      'likes': [],
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // GET ALL POSTS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getPosts() {
    return _firestore
        .collection('posts')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // =========================
  // DELETE POST
  // =========================

  Future<void> deletePost(
    String postId,
  ) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .delete();
  }

  // =========================
  // LIKE / UNLIKE POST
  // =========================

  Future<void> toggleLike(
    String postId,
    List<dynamic> currentLikes,
  ) async {
    final userId = _userId;

    final likes = List<String>.from(
      currentLikes.map(
        (item) => item.toString(),
      ),
    );

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await _firestore
        .collection('posts')
        .doc(postId)
        .update({
      'likes': likes,
    });
  }
}
