
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/upload_exercise.dart';
import 'package:chemgital/pages/App/view_exercise.dart';
import 'package:chemgital/pages/widgets/drawer.dart';
import 'package:chemgital/services/exercise_service.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  late ExerciseService _exerciseService;
  bool _isLoading = true;
  String? role;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _exerciseService = Provider.of<ExerciseService>(context, listen: false);
    _exerciseService.getAllExercise().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
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
        title: SafeArea(
          child: Text(
            'Exercise',
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Colors.white,),
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
      backgroundColor: const Color(0xFF040C23),
      drawer: CustomDrawer(),
      body: Consumer<ExerciseService>(
        builder: (context, exerciseService, _){
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } 
          else if (exerciseService.exerciseData.isEmpty) {
            return Center(
              child: Text(
                'No exercise available',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            );
          }
          else {
            return ListView.builder(
              itemCount: exerciseService.exerciseData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewExercise(
                          exerciseData: exerciseService.exerciseData[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Color(0xFF040C23),
                    elevation: 5,
                    margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.assignment, color : Colors.white),
                        title: Text(
                          exerciseService.exerciseData[index]['title'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                         
                        trailing: (role == 'admin')
                        ? PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                setState(() {
                                  _isLoading = true;
                                });
                                _exerciseService.deleteExercise(
                                  exerciseService.exerciseData[index]['id'],
                                ).then((_) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }
                            },
                          )
                        : FutureBuilder<bool>(
                            future: _exerciseService.checkSubmission(
                              exerciseService.exerciseData[index]['id'],
                              FirebaseAuth.instance.currentUser!.uid,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasData) {
                                if (snapshot.data!) {
                                  return const Icon(Icons.check, color: Colors.green);
                                }
                                else {
                                  return const Icon(Icons.arrow_forward_ios, color: Colors.white);
                                }
                              }
                              return Container();
                            },
                          ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: 
      (role == 'admin')
      ? Container(
          decoration: BoxDecoration(
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
            shape: BoxShape.circle,
          ),
          child: FractionallySizedBox(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadExercise(),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        )
      : null,
    );
  }
}