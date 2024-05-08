import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chemgital/models/question.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:chemgital/services/quiz_service.dart';
import 'package:chemgital/pages/App/quiz/score_screen.dart';
import 'package:chemgital/global/toast.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key, required this.quizId}) : super(key: key);

  final String quizId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late PageController pageController;
  List<Question> questions = [];
  QuizService quizService = QuizService();
  double score = 0;
  bool isLoading = true;
  Color selectedColor = Colors.transparent;
  int selectedOptionIndex = -1;
  List<int> correctAnswer = []; //1 = correct, 0 = incorrect, 2 = not answered
  bool isCountdownCompleted = false;
  String username = '';
  Color correctColor = Colors.white;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _loadQuiz();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final loadedQuestions = await quizService.getQuiz(widget.quizId);
      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (error) {
      print('Error loading quiz: $error');
      // Handle error loading quiz
    }
  }

  Future<void> _loadUserData() async {
      UserData userData = await FirebaseAuthService().getUserData();
      setState(() {
        username = userData.username;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Quiz',
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Do you want to exit?'),
                  content: Text('All progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text('Yes'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        backgroundColor: Color(0xFF040C23),
      ),
      backgroundColor: Color(0xFF040C23),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: pageController,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    SlideCountdown(
                      duration: Duration(seconds: 32),
                      icon: Icon(Icons.timer, color: Colors.white),
                      onDone: () {
                        if (!isCountdownCompleted) {
                          correctAnswer.add(2);
                          _checkAnswer(questions[index].options[0], index);
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Question ${index + 1} of ${questions.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 100,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFA44AFF),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            questions[index].question,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ...questions[index].options.map((option) {
                      return GestureDetector(
                        onTap: () {
                          _checkAnswer(option, index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: questions[index].options.indexOf(option) == selectedOptionIndex ? selectedColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: questions[index].options.indexOf(option) == index ? correctColor : Colors.white, width: 1.5),
                          ),
                          child: Center( 
                            child: Text(
                              option,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }

  void _nextQuestionOrFinish(int currentIndex) {
    if (currentIndex < questions.length - 1) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          selectedColor = Colors.transparent;
          correctColor = Colors.white;
        });
        pageController.nextPage(duration: Duration(milliseconds: 250), curve: Curves.ease);
      });
    } else {
      dispose();
      Future.delayed(Duration(seconds: 2), () {
        double totalScore = score / questions.length * 100;
        quizService.saveScore(widget.quizId, totalScore, FirebaseAuth.instance.currentUser!.uid, username);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ScoreScreen(score: score , totalQuestions: questions.length, correctAnswer: correctAnswer)));
      });
    }
  }

  void _checkAnswer(String selectedOption, int currentIndex) {
    if (questions[currentIndex].answer == questions[currentIndex].options.indexOf(selectedOption)) {
      showToast(message: 'Correct');
      score++;
      correctAnswer.add(1);
      setState(() {
        isCountdownCompleted = true;
        selectedOptionIndex = questions[currentIndex].options.indexOf(selectedOption);
        selectedColor = Colors.green;
      });
    } else {
      showToast(message: 'Incorrect');
      correctAnswer.add(0);
      setState(() {
        isCountdownCompleted = true;
        selectedOptionIndex = questions[currentIndex].options.indexOf(selectedOption);
        selectedColor = Colors.red;
        correctColor = Colors.green;
      });
    }
    _nextQuestionOrFinish(currentIndex);
  }
}
