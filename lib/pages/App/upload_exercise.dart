import 'dart:io';
import 'package:chemgital/global/toast.dart';
import 'package:chemgital/pages/App/exercise_page.dart';
import 'package:chemgital/services/exercise_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class UploadExercise extends StatefulWidget {
  const UploadExercise({super.key});

  @override
  State<UploadExercise> createState() => _UploadExerciseState();
}

class _UploadExerciseState extends State<UploadExercise> {
  final ExerciseService _exerciseService = ExerciseService();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _isPosting = false;
  File? exerciseFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Upload Exercise',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  
                ),
                style: TextStyle(color: Colors.white),
                minLines: 10,
                maxLines: null,
              ),
              const SizedBox(height: 20),
        
              exerciseFile != null
                ? Card(
                    color: Color(0xFF040C23),
                    elevation: 5,
                    child: ListTile(
                      leading: const Icon(Icons.file_copy, color: Colors.white),
                      title: Text(
                        exerciseFile!.path.split('/').last,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            exerciseFile = null;
                          });
                        },
                      ),
                    ),
                  )
        
                : GestureDetector(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
        
                      if (result != null) {
                        setState(() {
                          exerciseFile = File(result.files.single.path!);
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Center(
                        child: Text(
                          'Select file',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              GestureDetector(
                  onTap: () async {
                    if (_isPosting) return; 
                    if (_titleController.text.isEmpty) {
                      showToast(message: 'Please fill the title');
                    if (exerciseFile == null) {
                      showToast(message: 'Please select a file');
                    }
                    return;
                    }
        
                    setState(() {
                      _isPosting = true; 
                    });
        
                    try {
                      await _exerciseService.createExercise(
                        _titleController.text,
                        _descriptionController.text,
                        exerciseFile!,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const ExercisePage()),
                        (route) => false,
                      );
                    } catch (e) {
                      showToast(message: 'Failed to post');
                    } finally {
                      setState(() {
                        _isPosting = false; 
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0, .6, 1],
                        colors: [
                          Color(0xFFDF98FA),
                          Color(0xFFB070FD),
                          Color(0xFF9055FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: _isPosting
                          ? CircularProgressIndicator( 
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

    );
  }
}