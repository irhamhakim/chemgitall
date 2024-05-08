import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chemgital/global/toast.dart';
import 'package:chemgital/models/userdata.dart';



class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {

    try {
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);

      UserData userdata = UserData (username: username, uid: credential.user!.uid, email: email, role: 'user', score: 0);
      await _firestore.collection('users').doc(credential.user!.uid).set(userdata.toJson());

      return credential.user;
      
    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;

  }


  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }

    }
    return null;

  }

  Future<UserData> getUserData() async {
    User user = _auth.currentUser!;
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
    return UserData.fromSnap(snapshot);
  }

}

