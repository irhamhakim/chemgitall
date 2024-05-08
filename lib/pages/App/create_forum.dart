import 'dart:io';

import 'package:chemgital/global/toast.dart';
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/forum_page.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:chemgital/services/forum_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateForum extends StatefulWidget {
  const CreateForum({super.key});

  @override
  State<CreateForum> createState() => _CreateForumState();
}

class _CreateForumState extends State<CreateForum> {

  final ForumsService _forumService = ForumsService();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  UserData? userData;
  File? imageFile;
  bool _isPosting = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {

      UserData userData = await FirebaseAuthService().getUserData();
      setState(() {
        this.userData = userData;
      });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Add discussion',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                minLines: 5,
                maxLines: null,
              ),
        
              const SizedBox(height: 20.0),
        
              imageFile != null
                  ? GestureDetector(
                      onTap: () {
                        showImageViewer(
                          doubleTapZoomable: true,
                          context,
                          FileImage(imageFile!), 
                        );
                      },
                      child: Stack( children: [
                        Image.file(
                          imageFile!,
                          width: double.infinity,
                          height: 350.0,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 10.0,
                          right: 10.0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imageFile = null;
                              });
                            },
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 30.0,
                            ),
                          ),
                        ),
                    ],),
                    )
        
                  : InkWell(
                      onTap: () {
                        FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'png'],
                        ).then((value) {
                          if (value != null) {
                            setState(() {
                              imageFile = File(value.files.single.path!);
                            });
                          }
                        });
                      },
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Color(0xFFA44AFF),
                        size: 50.0,
                      ),
                    ),
        
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () async {
                  if (_isPosting) return; 
                  if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                    showToast(message: 'Please fill all fields');
                    return;
                  }

                  setState(() {
                    _isPosting = true; 
                  });

                  try {
                    await _forumService.createForum(
                      _titleController.text,
                      _descriptionController.text,
                      userData!.uid,
                      userData!.username,
                      imageFile,
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Forum()),
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
                  width: double.infinity,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isPosting
                        ? CircularProgressIndicator( 
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}