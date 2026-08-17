import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  Future<String> uploadProfilePhoto(File file) async {
    final ref = _storage
        .ref()
        .child('users')
        .child(_userId)
        .child('profile')
        .child('profile_photo.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  Future<String> uploadCoverPhoto(File file) async {
    final ref = _storage
        .ref()
        .child('users')
        .child(_userId)
        .child('cover')
        .child('cover_photo.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}
