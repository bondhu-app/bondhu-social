import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _myUid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // =========================
  // SEARCH USERS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      searchUsers(String text) {
    final query = text.trim().toLowerCase();

    if (query.isEmpty) {
      return _firestore
          .collection('users')
          .limit(20)
          .snapshots();
    }

    return _firestore
        .collection('users')
        .where(
          'searchName',
          isGreaterThanOrEqualTo: query,
        )
        .where(
          'searchName',
          isLessThan: '$query\uf8ff',
        )
        .limit(20)
        .snapshots();
  }

  // =========================
  // SEND FRIEND REQUEST
  // =========================

  Future<void> sendFriendRequest(
    String receiverId,
  ) async {
    if (receiverId == _myUid) {
      throw Exception(
        'You cannot send a request to yourself.',
      );
    }

    final existingRequest = await _firestore
        .collection('friendRequests')
        .where(
          'senderId',
          isEqualTo: _myUid,
        )
        .where(
          'receiverId',
          isEqualTo: receiverId,
        )
        .limit(1)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      return;
    }

    await _firestore
        .collection('friendRequests')
        .add({
      'senderId': _myUid,
      'receiverId': receiverId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // ACCEPT REQUEST
  // =========================

  Future<void> acceptFriendRequest(
    String requestId,
    String senderId,
  ) async {
    final batch = _firestore.batch();

    final requestRef = _firestore
        .collection('friendRequests')
        .doc(requestId);

    final myFriendRef = _firestore
        .collection('users')
        .doc(_myUid)
        .collection('friends')
        .doc(senderId);

    final senderFriendRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(_myUid);

    batch.update(requestRef, {
      'status': 'accepted',
    });

    batch.set(myFriendRef, {
      'friendId': senderId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(senderFriendRef, {
      'friendId': _myUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // =========================
  // REJECT REQUEST
  // =========================

  Future<void> rejectFriendRequest(
    String requestId,
  ) async {
    await _firestore
        .collection('friendRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',
    });
  }

  // =========================
  // RECEIVED REQUESTS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getReceivedRequests() {
    return _firestore
        .collection('friendRequests')
        .where(
          'receiverId',
          isEqualTo: _myUid,
        )
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .snapshots();
  }

  // =========================
  // MY FRIENDS
  // =========================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getFriends() {
    return _firestore
        .collection('users')
        .doc(_myUid)
        .collection('friends')
        .snapshots();
  }
}
