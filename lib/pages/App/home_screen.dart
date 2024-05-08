import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/pages/App/profile_page.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chemgital/global/toast.dart';
import 'package:chemgital/pages/widgets/drawer.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomeScreen> {

  String? username; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      UserData userData = await FirebaseAuthService().getUserData();
      setState(() {
        username = userData.username; 
      });
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      drawer : Builder(
      builder: (BuildContext context) {
        return CustomDrawer();  
      },
    ),
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Color(0xFF040C23),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(),
              height: height * 0.35,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: Icon(
                                  Icons.sort,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              const SizedBox(
                                width: 24,
                              ),
                              Text(
                                'CHEMGITAL',
                                style: GoogleFonts.poppins(
                                    fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 35,
                            ),
                            offset: Offset(-10, 45),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<String>(
                                  height: 40,
                                  child: Text('Profile', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent)),
                                  value: 'profile',
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem<String>(
                                  height: 40,
                                  child: Text('Logout', style: GoogleFonts.poppins(color: Colors.deepPurpleAccent)),
                                  value: 'logout',
                                ),
                              ];
                            },
                            onSelected: (String value) {
                              if (value == 'profile') {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
                              } else if (value == 'logout') {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushNamed(context, "/login");
                                  showToast(message: "Successfully signed out");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Hello, \n",
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              color: Color(0xFFA19CC5),
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                //only take first name
                                text: username.toString().split(" ")[0],
                                style: GoogleFonts.poppins(
                                  fontSize: 35,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF040C23),
                border: Border(top: BorderSide(color: Color(0xFFA44AFF), width: 3)),
              ),
              height: height * 0.65,
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/notes");
                        },
                        child: Container(
                          height: height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.library_books,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Notes',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Get your notes here',
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: -90,
                                  right: -80,
                                  child: SvgPicture.asset('assets/svg/book.svg', height: 280),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/exercise");
                        },
                        child: Container(
                          height: height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.assignment,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Exercise',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Test your knowledge',
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: -70,
                                  right: -50,
                                  child: SvgPicture.asset('assets/svg/exercise.svg', height: 270),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/rooms");
                        },
                        child: Container(
                          height: height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.forum,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Rooms',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Share with others',
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: -69,
                                  right: -80,
                                  child: SvgPicture.asset('assets/svg/room.svg', width: 280),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/quiz");
                        },
                        child: Container(
                          height: height * 0.24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
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
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 20),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            Icons.quiz,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Quiz',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Let\'s have some fun!',
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: -80,
                                  right: -65,
                                  child: SvgPicture.asset('assets/svg/quiz.svg', height: 270),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}
