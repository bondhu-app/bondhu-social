import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class VideoService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // =========================
  // PICK VIDEO
  // =========================

  Future<XFile?> pickVideo() async {
    final video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    return video;
  }

  // =========================
  // UPLOAD VIDEO
  // =========================

  Future<String> uploadVideo(
    XFile video,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final file = File(video.path);

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${user.uid}.mp4';

    final storageRef = _storage
        .ref()
        .child('videos')
        .child(user.uid)
        .child(fileName);

    final uploadTask =
        await storageRef.putFile(file);

    final downloadUrl =
        await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }

  // =========================
  // CREATE VIDEO POST
  // =========================

  Future<void> createVideoPost({
    required String videoUrl,
    required String caption,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final userData =
        userDoc.data() ?? {};

    await _firestore
        .collection('posts')
        .add({
      'userId': user.uid,
      'userName':
          userData['name'] ?? 'Bondhu User',
      'userPhotoUrl':
          userData['photoUrl'] ?? '',
      'type': 'video',
      'videoUrl': videoUrl,
      'text': caption.trim(),
      'likes': [],
      'commentsCount': 0,
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // PICK + UPLOAD + POST
  // =========================

  Future<void> createVideoPostFromGallery({
    required String caption,
  }) async {
    final video = await pickVideo();

    if (video == null) {
      return;
    }

    final videoUrl =
        await uploadVideo(video);

    await createVideoPost(
      videoUrl: videoUrl,
      caption: caption,
    );
  }
}
