import 'package:chemgital/global/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)!.settings.name;

    return Drawer(
      width: 200,
      child: Container(
        color: Color(0xFF040C23),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF040C23),
                    ),
                    child: Text(
                      'Chemgital',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        color: currentRoute == '/home' ? Color(0xFFA44AFF) : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Notes',
                      style: GoogleFonts.poppins(
                        color: currentRoute == '/notes' ? Color(0xFFA44AFF) : Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/notes');
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Exercise',
                      style: GoogleFonts.poppins(
                        color: currentRoute == '/exercise' ? Color(0xFFA44AFF) : Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/exercise');
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Rooms',
                      style: GoogleFonts.poppins(
                        color: currentRoute == '/rooms' ? Color(0xFFA44AFF) : Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/rooms');
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Quiz',
                      style: GoogleFonts.poppins(
                        color: currentRoute == '/quiz' ? Color(0xFFA44AFF) : Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/quiz');
                    },
                    
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/login');
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, "/login");
                showToast(message: "Successfully signed out");
              },
            ),
          ],
        ),
      ),
    );
  }

}
