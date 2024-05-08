
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/comment_page.dart';
import 'package:chemgital/pages/widgets/drawer.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chemgital/services/forum_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';


class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  late ForumsService _forumService;
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? role;

  @override
  void initState(){
    super.initState();
    loadUserData();
    _forumService = Provider.of<ForumsService>(context, listen: false);
    _forumService.getForums().then((_) {
      setState(() {
        _isLoading = false;
      });
    }); 
  }

  Future<void> loadUserData() async{
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
            'Rooms',
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.sort, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _forumService.getForums().then((_) {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
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
      body: Consumer<ForumsService>(
        builder: (context, forumService, _) {
          if (_isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (forumService.forumData.isEmpty) {
            return Center(
              child: Text(
                'Start discuss now',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }
          else {
            return ListView.builder(
              itemCount: forumService.forumData.length,
              itemBuilder: (context, index) {
                return Card(
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
                    
                              if (forumService.forumData[index]['uid'] == FirebaseAuth.instance.currentUser!.uid)
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
                                  forumService.forumData[index]['username'],
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
                            forumService.forumData[index]['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 10),

                          if(forumService.forumData[index].containsKey('imageUrl') == true && forumService.forumData[index]['imageUrl'] != null)...[
                            GestureDetector(
                              onTap: () {
                                showImageViewer(
                                  doubleTapZoomable: true,
                                  context,
                                  NetworkImage(
                                    forumService.forumData[index]['imageUrl'],
                                  ),
                                );
                              },
                              child: Image.network(
                                forumService.forumData[index]['imageUrl'],
                                width: double.infinity,
                                height: 350.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          Text(
                            forumService.forumData[index]['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),


                          Text(
                            Jiffy.parseFromDateTime(forumService.forumData[index]['timestamp'].toDate()).fromNow().toString(),
                            style: GoogleFonts.poppins(   
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                              color: Color(0xFFA19CC5),
                            ),
                          ),
                                          
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.comment, color: Colors.white, size: 25),

                                  const SizedBox(width: 10),
                                  Text(
                                    (forumService.forumData[index]['comments'] != null && forumService.forumData[index]['comments'].isNotEmpty)
                                      ? forumService.forumData[index]['comments'].length.toString()
                                      : '0', 
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CommentPage(
                                        forumData: forumService.forumData[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  ' View Discussion',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          
                        ],
                      ),
                    ),

                    if (forumService.forumData[index]['uid'] == FirebaseAuth.instance.currentUser!.uid || role == 'admin')
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
                
                                          await forumService.deleteForum(
                                            forumService.forumData[index]['id'],
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

      floatingActionButton: Container(
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
              Navigator.pushNamed(context, '/create_forum');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}