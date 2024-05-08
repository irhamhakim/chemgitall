/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chemgital/models/question.dart';

class QuizController extends ChangeNotifier {
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  PageController _pageController = PageController();
  PageController get getPageController => _pageController;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;

  int _correctAnswerIndex = -1;
  int get correctAnswerIndex => _correctAnswerIndex;

  int _selectedAnswerIndex = -1;
  int get selectedAnswerIndex => _selectedAnswerIndex;

  int _questionNumber = 1;
  int get questionNumber => _questionNumber;

  void setQuestions(List<Question> questions) {
    _questions = questions;
    notifyListeners();
  }

  void checkAnswer(int selectedIndex, int indexQuestion) {
    _isAnswered = true;
    _selectedAnswerIndex = selectedIndex;
    if (selectedIndex == _questions[indexQuestion].answer) {
      _correctAnswerIndex = selectedIndex;
    } else {
      _correctAnswerIndex = _questions[indexQuestion].answer;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_pageController.page!.toInt() < _questions.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 250), curve: Curves.ease);
      _isAnswered = false;
      _correctAnswerIndex = -1;
      _selectedAnswerIndex = -1;
      _questionNumber++;
    } else {
      // Navigate to the score screen
      Get.toNamed('/score');
    }
  }

  void updateQuestionNumber(int index) {
    _questionNumber = index + 1;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
 */