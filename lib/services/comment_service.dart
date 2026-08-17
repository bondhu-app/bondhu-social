import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
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
  // ADD COMMENT
  // =========================

  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    if (text.trim().isEmpty) {
      return;
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await commentRef.set({
      'userId': user.uid,
      'userName': userData['name'] ?? 'Bondhu User',
      'userPhotoUrl': userData['photoUrl'] ?? '',
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('posts')
        .doc(postId)
        .update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  // =========================
  // GET COMMENTS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy(
          'createdAt',
          descending: false,
        )
        .snapshots();
  }

  // =========================
  // DELETE COMMENT
  // =========================

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) {
      return;
    }

    final data = commentDoc.data();

    if (data?['userId'] != _userId) {
      throw Exception(
        'You can only delete your own comment.',
      );
    }

    await commentRef.delete();

    await _firestore
        .collection('posts')
        .doc(postId)
        .update({
      'commentsCount': FieldValue.increment(-1),
    });
  }
}
