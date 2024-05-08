import 'package:chemgital/global/toast.dart';
import 'package:chemgital/models/question.dart';
import 'package:chemgital/models/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> quizData = [];


  Future<void> createQuiz(String title, String description, List<Question> questions) async{

      DocumentReference quizRef = await _firestore.collection('quizzes').add({
        'title': title,
        'description': description,
      });

      List<Map<String, dynamic>> questionDataList = [];
      questions.forEach((question) {
        questionDataList.add({
          'answer': question.answer,
          'question': question.question,
          'options': question.options,
        });
      });

      await quizRef.collection('questions').doc().set({
        'questions': questionDataList,
      });

      showToast(message: 'Quiz created successfully');
  }

  Future<void> deleteQuiz(String quizId) async{
    await _firestore.collection('quizzes').doc(quizId).delete();
    showToast(message: 'Quiz deleted successfully');
  }

  Future<List<Question>> getQuiz(String quizId) async {
    List<Map<String, dynamic>> questions = [];
    List<Question> questionList = [];
    QuerySnapshot querySnapshot =
        await _firestore.collection('quizzes').doc(quizId).collection('questions').get();
    querySnapshot.docs.forEach((doc) {
      questions.addAll(List<Map<String, dynamic>>.from(doc['questions']));
    });
    questions.forEach((question) {
      questionList.add(Question(
        question: question['question'],
        answer: question['answer'],
        options: List<String>.from(question['options']),
      ));
    });

    return questionList;
  }

  Future<void> saveScore(String quizId, double score, String userId, String username) async {
    await _firestore.collection('quizzes').doc(quizId).collection('scores').doc(userId).set({
      'score': score,
      'username': username,
    });

    //update field of score in users doc
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    int currentScore = doc['score'];
    await _firestore.collection('users').doc(userId).update({
      'score': currentScore + score.toInt(),
    });
  }

  Future<bool> checkIfUserHasTakenQuiz(String quizId, String userId) async {
    DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).collection('scores').doc(userId).get();
    return doc.exists;
  }

  Future<double> getScore(String quizId, String userId) async {
    DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).collection('scores').doc(userId).get();
    return doc['score'];
  }

  Future<List<UserData>> getUserData() async {
  List<UserData> userDataList = [];
  QuerySnapshot querySnapshot = await _firestore.collection('users').where('role', isEqualTo: 'user').get(); // Filter by role 'user'
  querySnapshot.docs.forEach((doc) {
    userDataList.add(UserData(
      username: doc['username'],
      uid: doc['uid'],
      email: doc['email'],
      role: doc['role'],
      score: doc['score'],
    ));
  });
  return userDataList;
}
  
}