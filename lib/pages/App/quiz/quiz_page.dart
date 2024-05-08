

import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/quiz/leaderboard.dart';
import 'package:chemgital/pages/App/quiz/start_quiz.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:chemgital/services/quiz_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chemgital/pages/App/quiz/create_quiz_page.dart';
import 'package:chemgital/pages/App/quiz/quiz_screen.dart';
import 'package:chemgital/pages/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  QuizService _quizService = QuizService();
  int score = 0;
  String role = '';
  bool isAttempted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
    
  }

  Future<void> _loadUserData() async {
      UserData userData = await FirebaseAuthService().getUserData();
      setState(() {
        role = userData.role;
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Quiz',
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.sort, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        backgroundColor: Color(0xFF040C23),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Color(0xFFA44AFF),
            height: 4.0,
          ),
        ),
      ),
      backgroundColor: Color(0xFF040C23),
      drawer: CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's play quiz",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Let\'s see who will be in the leaderboard',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Leaderboard(),
                  ),
                );
              },
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, .6, 1],
                    colors: [
                      Color(0xFFDF98FA),
                      Color(0xFFB070FD),
                      Color(0xFF9055FF)
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard, color: Colors.purple, size: 40),
                    SizedBox(width: 20),
                    Text(
                      'Leaderboard',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildQuizList(),
            ),
          ],
        ),
      ),
      floatingActionButton: role == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateQuizPage(),
                  ),
                );
              },
              backgroundColor: Color(0xFFA44AFF),
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
      
    );
}

  Widget _buildQuizList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: Color(0xFF040C23),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  onTap: () async {
                    if (!isAttempted) {
                      bool hasTakenQuiz = await _quizService.checkIfUserHasTakenQuiz(document.id, FirebaseAuth.instance.currentUser!.uid);
                      setState(() {
                        isAttempted = hasTakenQuiz;
                      });
                      if (!hasTakenQuiz) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StartQuiz(quizId: document.id, title: data['title'], description: data['description']),
                          ),
                        );
                      }
                    }
                  },
                  leading: Icon(Icons.quiz, color: Colors.white),
                  title: Text(
                    data['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    data['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: 
                  (role == 'admin') ?
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete this quiz?'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    String quizId = document.id;
                                    QuizService().deleteQuiz(quizId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  )
                  : FutureBuilder<bool>(
                    future: _quizService.checkIfUserHasTakenQuiz(document.id, FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        if (snapshot.data!) {
                          return FutureBuilder<double>(
                            future: _quizService.getScore(document.id, FirebaseAuth.instance.currentUser!.uid),
                            builder: (context, scoreSnapshot) {
                              if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (scoreSnapshot.hasData) {
                                double score = scoreSnapshot.data!;
                                return Text(
                                  '${score.toStringAsFixed(0)}%', // Adjust formatting as needed
                                  style: TextStyle(
                                    color: score >= 50 ? Colors.green : Colors.red,
                                    fontSize: 20,
                                  ),
                                );
                              } else if (scoreSnapshot.hasError) {
                                return Text(
                                  'Error retrieving score',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                return Container(); // Handle loading state
                              }
                            },
                          );
                        } else {
                          return Icon(Icons.arrow_forward_ios, color: Colors.white);
                        }
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
