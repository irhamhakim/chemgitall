import 'package:flutter/material.dart';
import 'package:chemgital/pages/App/quiz/quiz_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({Key? key, required this.score, required this.totalQuestions, required this.correctAnswer}) : super(key: key);

  final double score;
  final int totalQuestions;
  final List<int> correctAnswer;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF040C23), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueAccent,
                      Colors.greenAccent,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${(widget.score / widget.totalQuestions * 100).toStringAsFixed(0)}' + '%',
                    style: GoogleFonts.poppins(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.totalQuestions,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10), // Adjust spacing as needed
                  child: Container(
                    width: 40,
                    height: 40, 
                    child: Center(
                      child: Container(
                        width: 40, 
                        height: 40, 
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.correctAnswer[index] == 1 ? Colors.green : widget.correctAnswer[index] == 0 ? Colors.red : Colors.yellowAccent,
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'You scored ${widget.score.round()} out of ${widget.totalQuestions}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            FadeTransition(
              opacity: _animation,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage()));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Color(0xFFA44AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Return to Quiz Page',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
