
import 'dart:io';

import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/exercise_page.dart';
import 'package:chemgital/pages/App/pdf_viewer.dart';
import 'package:chemgital/services/exercise_service.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ViewExercise extends StatefulWidget {
  final Map<String, dynamic> exerciseData;
  const ViewExercise({required this.exerciseData, Key? key}) : super(key: key);

  @override
  State<ViewExercise> createState() => _ViewExerciseState();
}

class _ViewExerciseState extends State<ViewExercise> {

  ExerciseService _exerciseService = ExerciseService();
  String? role;
  String? username;
  bool _isLoading = true;
  File? submissionFile;

  @override
  void initState() {
    super.initState();
    _exerciseService = Provider.of<ExerciseService>(context, listen: false);
    _exerciseService.getExerciseSubmission(widget.exerciseData['id']).then((_) {
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
        username = userData.username;
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF040C23),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color(0xFFA44AFF),
            height: 4.0,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF040C23),
      body: SingleChildScrollView(
        child : Column(
          children: [
            Card(
              color: Color(0xFF040C23),
                    margin: const EdgeInsets.all(15),
                    elevation: 5,
                    child: Stack(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.exerciseData['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.exerciseData['description'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PdfViewerScreenState(
                                        pdfUrl: widget.exerciseData['link'],
                                        title: widget.exerciseData['title'],
                                      ),
                                    ),
                                  );     
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children:  [
                                        Icon(Icons.picture_as_pdf, color: Colors.white, size: 50),
                                        SizedBox(height: 10),
                                        Text(
                                          widget.exerciseData['title'] + '.pdf',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.exerciseData['date'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFA19CC5),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                          
                        ),
                        role == 'admin'
                        ? Positioned(
                            right: 0,
                            top: 0,
                            child : PopupMenuButton(
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete Exercise'),
                                        content: const Text('Are you sure you want to delete this exercise?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isLoading = true;
                                              });
                                              _exerciseService.deleteExercise(
                                              widget.exerciseData['id'],
                                            ).then((_) {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const ExercisePage(),
                                                ),
                                                (route) => false,
                                              );
                                            });
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          )
                        : Container(),
                      ],
                    ),
            ),
            Center(
              child: Text(
                'Submissions',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15, child: Divider(color: Colors.white, height: 10, thickness: 1, indent: 15, endIndent: 15),),
            const SizedBox(height: 10),
            Consumer<ExerciseService>(
              builder: (context, exerciseService, child) {
                if (_isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else if (role == 'admin' && exerciseService.exerciseSubmission.isEmpty) {
                  return const Center(
                    child: Text(
                      'No submission yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  );
                }

                List<dynamic> filteredSubmissions = exerciseService.exerciseSubmission.where((element) => element['uid'] == FirebaseAuth.instance.currentUser!.uid).toList();
                
                if (role == 'user' && filteredSubmissions.isEmpty) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              submissionFile = File(value.files.single.path!);
                            });
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Submit Exercise'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        color: Color(0xFF040C23),
                                        margin: const EdgeInsets.all(15),
                                        elevation: 5,
                                        child: ListTile(
                                          leading: Icon(Icons.file_copy, color: Colors.white),
                                          title: Text(
                                            submissionFile!.path.split('/').last,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text('Are you sure you want to submit this exercise?'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        _exerciseService.submitExercise(
                                          submissionFile!.path.split('/').last,
                                          submissionFile!,
                                          widget.exerciseData['id'],
                                          FirebaseAuth.instance.currentUser!.uid,
                                          username!,
                                        ).then((_) {
                                          setState(() {
                                            _isLoading = false;
                                            submissionFile = null;
                                          });
                                        });
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Add Submission',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    )
                  );
                }

                role == 'user' ? filteredSubmissions = filteredSubmissions : filteredSubmissions = exerciseService.exerciseSubmission;
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredSubmissions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PdfViewerScreenState(
                              pdfUrl: filteredSubmissions[index]['link'],
                              title: filteredSubmissions[index]['name'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Color(0xFF040C23),
                        elevation: 5,
                        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.assignment, color : Colors.white),
                            title: Text(
                              filteredSubmissions[index]['username'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              filteredSubmissions[index]['date'],
                              style: GoogleFonts.poppins(
                                color: Color(0xFFA19CC5),
                                fontSize: 15,
                              ),
                            ),
                            trailing: 
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PopupMenuButton(
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
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Delete Submission'),
                                              content: const Text('Are you sure you want to delete this submission?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    _exerciseService.deleteExerciseSubmission(
                                                      widget.exerciseData['id'],
                                                      filteredSubmissions[index]['id'],
                                                    ).then((_) {
                                                      setState(() {
                                                        _isLoading = false;
                                                      });
                                                    });
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                              ],
                            )
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),

      ),
    );
  }
}

