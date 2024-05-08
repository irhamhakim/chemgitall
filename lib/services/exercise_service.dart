import 'dart:io';

import 'package:chemgital/global/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class ExerciseService extends ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _exerciseData = [];
  List<Map<String, dynamic>> get exerciseData => _exerciseData;
  List<Map<String, dynamic>> _exerciseSubmission = [];
  List<Map<String, dynamic>> get exerciseSubmission => _exerciseSubmission;
  List<Map<String, dynamic>> _exerciseSubmissionByUid = [];
  List<Map<String, dynamic>> get exerciseSubmissionByUid => _exerciseSubmissionByUid;


  Future<void> createExercise(String title, String? description, File file) async {

    DocumentReference docRef = _firestore.collection('exercises').doc();
    String docId = docRef.id;

    final reference = FirebaseStorage.instance.ref().child("pdfs/exercise/$docId.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadLink = await reference.getDownloadURL();

    await docRef.set({
      'id': docId,
      'title': title,
      'description': description,
      'link': downloadLink,
      'date': Jiffy.parseFromDateTime(DateTime.now()).yMMMMEEEEdjm,
    });

    _exerciseData.add({
      'id': docId,
      'title': title,
      'description': description,
      'link': downloadLink,
      'date': Jiffy.parseFromDateTime(DateTime.now()).yMMMMEEEEdjm,
      'submission': [],
    });

    notifyListeners();

    showToast(message: "Exercise created successfully");
  }

  Future getAllExercise() async {
    final results = await _firestore.collection('exercises').orderBy('date').get();
    _exerciseData = results.docs.map((e) => e.data() ).toList();
  }

  Future<void> submitExercise(String fileName, File file, String id, String uid, String username) async {

    DocumentReference docRef = _firestore.collection('exercises').doc(id).collection('submission').doc();
    String docId = docRef.id;

    final reference = FirebaseStorage.instance.ref().child("pdfs/exercise/submission/$docId.pdf");

    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() {});

    final downloadLink = await reference.getDownloadURL();

    await docRef.set({
      'id': docId,
      'uid': uid,
      'username': username,
      'name': fileName,
      'link': downloadLink,
      'date': Jiffy.parseFromDateTime(DateTime.now()).yMMMMdjm,
    });

    _exerciseSubmission.add({
      'id': docId,
      'uid': uid,
      'username': username,
      'name': fileName,
      'link': downloadLink,
      'date': Jiffy.parseFromDateTime(DateTime.now()).yMMMMdjm,
    });

    notifyListeners();

    showToast(message: "Exercise submitted successfully");
  }

  Future getExerciseSubmission(String id) async {
    final results = await _firestore.collection('exercises').doc(id).collection('submission').orderBy('date').get();
    _exerciseSubmission = results.docs.map((e) => e.data() ).toList();
  }

  Future<bool> checkSubmission(String id, String uid) async {
    final results = await _firestore.collection('exercises').doc(id).collection('submission').where('uid', isEqualTo: uid).get();
    return results.docs.isNotEmpty;
  }

  Future<void> deleteExercise(String exerciseId) async {
    
    final reference = FirebaseStorage.instance.ref().child("pdfs/exercise/$exerciseId.pdf");
    await reference.delete();

    await _firestore.collection('exercises').doc(exerciseId).delete();

    _exerciseData.removeWhere((element) => element['id'] == exerciseId);

    notifyListeners();

    showToast(message: 'Exercise deleted successfully');
  }

  Future<void> deleteExerciseSubmission(String exerciseId, String submissionId) async {
    
    final reference = FirebaseStorage.instance.ref().child("pdfs/exercise/submission/$submissionId.pdf");
    await reference.delete();

    await _firestore.collection('exercises').doc(exerciseId).collection('submission').doc(submissionId).delete();

    _exerciseSubmission.removeWhere((element) => element['id'] == submissionId);

    notifyListeners();

    showToast(message: 'Exercise submission deleted successfully');
  }

}