import 'package:flutter/material.dart';
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/services/quiz_service.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({Key? key}) : super(key: key);

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  QuizService quizService = QuizService();
  List<UserData> leaderboard = [];

  @override
  void initState() {
    super.initState();
    // Fetch leaderboard data
    quizService.getUserData().then((value) {
      setState(() {
        leaderboard = value..sort((a, b) => b.score.compareTo(a.score));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
      body: leaderboard.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA44AFF)),
              ),
            )
          : ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Text(
                        leaderboard[index].username,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Score: ${leaderboard[index].score}',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: index == 0 ? Colors.amber : index == 1 ? Colors.grey : index == 2 ? Colors.brown : Colors.blueGrey,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
