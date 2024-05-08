import 'dart:io';
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/forum_page.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:chemgital/services/forum_service.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  final Map<String, dynamic> forumData;
  const CommentPage({Key? key, required this.forumData}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late ForumsService _forumService;
  bool _isLoading = true;
  File? imageFile;
  UserData? userData;
  bool _isSending = false;
  TextEditingController _commentController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _forumService = Provider.of<ForumsService>(context, listen: false);
    _forumService.getComments(widget.forumData['id']).then((_) {
      setState(() {
        _isLoading = false;
      });
    }); 
  }

  Future<void> _loadUserData() async {
      UserData _userData = await FirebaseAuthService().getUserData();
      setState(() {
        userData = _userData;
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Comments',
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
      body: 
      _isLoading
      ? const Center(
        child: CircularProgressIndicator(),
      )
      : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Card(
                color: Color(0xFF040C23),
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: Stack(
                  children: [
                    ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.account_circle, color: Colors.white, size: 30,),
                              const SizedBox(width: 10),
                              if (widget.forumData['uid'] == FirebaseAuth.instance.currentUser!.uid)
                                Text(
                                  'You',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Text(
                                  widget.forumData['username'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 10, child: Divider(color: Colors.white, height: 10, thickness: 1, indent: 0, endIndent: 0)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            widget.forumData['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if(widget.forumData.containsKey('imageUrl') == true && widget.forumData['imageUrl'] != null)...[
                            GestureDetector(
                              onTap: () {
                                showImageViewer(
                                  doubleTapZoomable: true,
                                  context,
                                  NetworkImage(
                                    widget.forumData['imageUrl'],
                                  ),
                                );
                              },
                              child: Image.network(
                                widget.forumData['imageUrl'],
                                width: double.infinity,
                                height: 350.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            widget.forumData['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            Jiffy.parseFromDateTime(widget.forumData['timestamp'].toDate()).fromNow().toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              color: Color(0xFFA19CC5),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    if (widget.forumData['uid'] == FirebaseAuth.instance.currentUser!.uid || userData!.role == 'admin')
                      Positioned(
                        top: 0,
                        right: 0,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            if (value == 'delete') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete discussion'),
                                    content: Text('Are you sure you want to delete this?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isLoading = true;
                                          });
                
                                          _forumService.deleteForum(
                                            widget.forumData['id'],
                                          );

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => Forum()),
                                            (route) => false,
                                          );
                                          
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              height: 40,
                              value: 'delete',
                              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent),),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Consumer<ForumsService>(
                builder: (context, forumService, _) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (forumService.commentData.isEmpty) {
                    return const Center(
                      child: Text(
                        'No comments yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true, 
                      physics: NeverScrollableScrollPhysics(), 
                      itemCount: forumService.commentData.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: const Color.fromARGB(255, 23, 10, 59),
                          elevation: 5,
                          margin: const EdgeInsets.all(10),
                          child: Stack(
                            children : [
                              ListTile(
                                title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, color: Colors.white, size: 30,),
                                      const SizedBox(width: 10),
                                      if (forumService.commentData[index]['uid'] == FirebaseAuth.instance.currentUser!.uid)
                                        Text(
                                          'You',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        )
                                      else
                                        Text(
                                          forumService.commentData[index]['username'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const SizedBox(height: 10, child: Divider(color: Colors.white, height: 10, thickness: 1, indent: 0, endIndent: 0)),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    forumService.commentData[index]['comment'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if(forumService.commentData[index].containsKey('imageUrl') == true && forumService.commentData[index]['imageUrl'] != null)...[
                                    GestureDetector(
                                      onTap: () {
                                        showImageViewer(
                                          doubleTapZoomable: true,
                                          context,
                                          NetworkImage(
                                            forumService.commentData[index]['imageUrl'],
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        forumService.commentData[index]['imageUrl'],
                                        width: double.infinity,
                                        height: 350.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  forumService.commentData[index]['timestamp'].runtimeType == DateTime
                                  ? Text(
                                      Jiffy.parseFromDateTime(forumService.commentData[index]['timestamp']).fromNow().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w200,
                                        color: Color(0xFFA19CC5),
                                      ),
                                    )
                                  : Text(
                                      Jiffy.parseFromDateTime(forumService.commentData[index]['timestamp'].toDate()).fromNow().toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w200,
                                        color: Color(0xFFA19CC5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                              if (forumService.commentData[index]['uid'] == FirebaseAuth.instance.currentUser!.uid || userData!.role == 'admin')
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.white),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Delete comment'),
                                              content: Text('Are you sure you want to delete this?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                          
                                                    await forumService.deleteComment(
                                                      widget.forumData['id'],
                                                      forumService.commentData[index]['id'],
                                                    );
                                                    
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        height: 40,
                                        value: 'delete',
                                        child: Text('Delete', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent),),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              Padding(padding: EdgeInsets.only(bottom: 80)),

            ],
          ),
        ),
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            color: Color(0xFF040C23), 
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Type your comment...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
                if (imageFile == null)
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
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
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showImageViewer(
                              doubleTapZoomable: true,
                              context,
                              FileImage(imageFile!), 
                            );
                          },
                          child: Image.file(
                            imageFile!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                imageFile = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isSending
                  ? const Padding(
                    padding: EdgeInsets.all(0),
                    child: CircularProgressIndicator(
                      color: Colors.purpleAccent,
                    ),
                  )

                  : IconButton(
                      icon: Icon(Icons.send, color: Colors.purpleAccent),
                      onPressed: () {

                        if (_commentController.text.isNotEmpty) {
                          setState(() {
                            _isSending = true;
                          });

                          _forumService.createComment(
                            widget.forumData['id'],
                            _commentController.text,
                            FirebaseAuth.instance.currentUser!.uid,
                            userData!.username,
                            imageFile,
                          ).then((_) {
                            setState(() {
                              _isSending = false;
                            });
                          });

                          _commentController.clear();
                          setState(() {
                            imageFile = null;
                          });
                        }
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

