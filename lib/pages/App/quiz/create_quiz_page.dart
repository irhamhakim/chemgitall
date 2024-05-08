import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chemgital/services/quiz_service.dart';
import 'package:chemgital/models/question.dart';

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({Key? key}) : super(key: key);

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<List<TextEditingController>> _optionControllers = [];
  List<TextEditingController> _questionControllers = [];
  List<Question> _questions = [];
  List<int> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _addQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Create Quiz',
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
            Navigator.pop(context);
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
      backgroundColor: const Color(0xFF040C23),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: Colors.white),
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _questions.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildQuestionCard(index);
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addQuestion,
              child: Text('Add Question'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _saveQuiz,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFA44AFF)),
              ),
              child: Text('Save Quiz', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      color: Color(0xFF040C23),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextFormField(
              controller: _questionControllers[index],
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _questions[index] = _questions[index].copyWith(question: value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Column(
              children: _questions[index].options.asMap().entries.map<Widget>((entry) {
                int optionIndex = entry.key;
                return _buildOptionRow(index, optionIndex);
              }).toList(),
            ),
            SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                _addOption(index);
              },
              child: Text(
                'Add Option',
                style: TextStyle(color: Colors.deepPurpleAccent),
              ),
            ),
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _removeQuestion(index);
                },
                child: Text('Remove Question', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(int questionIndex, int optionIndex) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: TextFormField(
              controller: _optionControllers[questionIndex][optionIndex],
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _questions[questionIndex].options[optionIndex] = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Option',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Radio<int>(
          value: optionIndex,
          groupValue: _selectedAnswers.length > questionIndex ? _selectedAnswers[questionIndex] : null,
          onChanged: (value) {
            setState(() {
              _selectedAnswers[questionIndex] = value!;
            });
          },
        ),
        if (_questions[questionIndex].options.length > 2) // Conditionally render the remove icon
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white),
          onPressed: () {
            _removeOption(questionIndex, optionIndex);
          },
        ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(Question(question: '', options: ['', ''], answer: 0));
      _questionControllers.add(TextEditingController());
      _optionControllers.add([TextEditingController(), TextEditingController()]);
      _selectedAnswers.add(0);
    });
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex].options.add('');
      _optionControllers[questionIndex].add(TextEditingController());
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    setState(() {
      _questions[questionIndex].options.removeAt(optionIndex);
      _optionControllers[questionIndex].removeAt(optionIndex);
    });
  }

  void _removeQuestion(int questionIndex) {
    setState(() {
      _questions.removeAt(questionIndex);
      _optionControllers.removeAt(questionIndex);
      _selectedAnswers.removeAt(questionIndex);
    });
  }

  void _saveQuiz() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty && _questions.isNotEmpty) {
      List<Question> questionList = _questions.map((question) {
        return Question(
          question: question.question,
          options: question.options,
          answer: _selectedAnswers[_questions.indexOf(question)],
        );
      }).toList();

      QuizService().createQuiz(title, description, questionList).then((_) {
        Navigator.pop(context);
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields and add at least one question'),
      ));
    }
  }
}
