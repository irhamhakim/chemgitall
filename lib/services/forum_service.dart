
import 'dart:io';

import 'package:chemgital/global/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/jiffy.dart';

class ForumsService extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> _forumData = [];
  List<Map<String, dynamic>> get forumData => _forumData;
  List<Map<String, dynamic>> _commentData = [];
  List<Map<String, dynamic>> get commentData => _commentData;

  Future<void> createForum(String title, String description, String uid, String username, File? imageFile) async {
    
    DocumentReference docRef = _firestore.collection('forums').doc();
    String forumId = docRef.id;

    String? imageUrl;
    if (imageFile != null) {
      final storageRef = _storage.ref().child('forum_images/$forumId.jpg');
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    await docRef.set({
      'id': forumId,
      'title': title,
      'description': description,
      'username': username,
      'uid': uid,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
    });

    _forumData.add({
      'id': forumId,
      'title': title,
      'description': description,
      'username': username,
      'uid': uid,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
      'comments': [],
    });

    notifyListeners();

    showToast(message: 'Discussion created successfully');
  }

  Future<void> deleteForum(String id) async {
    await _firestore.collection('forums').doc(id).delete();

    _forumData.removeWhere((element) => element['id'] == id);

    notifyListeners();

    showToast(message: 'Discussion deleted successfully');

  }

  Future<void> createComment(String forumId, String comment, String uid, String username, File? imageFile) async {

    DocumentReference docRef = _firestore.collection('forums').doc(forumId).collection('comments').doc();
    String commentId = docRef.id;

    String? imageUrl;
    if (imageFile != null) {
      final storageRef = _storage.ref().child('comment_images/$commentId.jpg');
      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    await docRef.set({
      'id': commentId,
      'comment': comment,
      'username': username,
      'uid': uid,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
    });

    _commentData.add({
      'id': commentId,
      'comment': comment,
      'username': username,
      'uid': uid,
      'imageUrl': imageUrl,
      'timestamp': DateTime.now(),
    });

    notifyListeners();

    showToast(message: 'Comment created successfully');

  }

  Future<void> deleteComment(String forumId, String commentId) async {

    await _firestore.collection('forums').doc(forumId).collection('comments').doc(commentId).delete();

    _commentData.removeWhere((element) => element['id'] == commentId);

    notifyListeners();

    showToast(message: 'Comment deleted successfully');
  }

  Future getForums() async{
    final result = await _firestore.collection('forums').orderBy('timestamp', descending: true).get();
    _forumData = result.docs.map((e) => e.data() ).toList();

    for (var i = 0; i < _forumData.length; i++) {
      final comments = await _firestore.collection('forums').doc(_forumData[i]['id']).collection('comments').get();
      _forumData[i]['comments'] = comments.docs.map((e) => e.data() ).toList();
    }
  }

  Future getComments(String forumId) async {
    final result = await _firestore.collection('forums').doc(forumId).collection('comments').orderBy('timestamp', descending: false).get();
    _commentData = result.docs.map((e) => e.data() ).toList();
  }
}