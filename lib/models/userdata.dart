import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class UserData{
  final String username;
  final String uid;
  final String email;
  final String role;
  final int score;
  
  const UserData({required this.username, required this.uid, required this.email, required this.role, required this.score});

  Map<String, dynamic> toJson() => {
    'username': username,
    'uid': uid,
    'email': email,
    'role': role,
    'score': score,
  };

  static UserData fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserData(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      role: snapshot['role'],
      score: snapshot['score'],
    );}
  
}