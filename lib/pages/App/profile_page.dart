import 'package:chemgital/global/toast.dart';
import 'package:chemgital/models/userdata.dart';
import 'package:chemgital/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  UserData? userData;
  bool isLoading = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      setState(() {
        isLoading = false;
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
      appBar: AppBar(
        title: SafeArea(
          child: Text(
            'Profile',
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.pinkAccent,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                    
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
                    child: TextField(
                      controller: _nameController..text = userData!.username,
                      style: const TextStyle(color: Colors.white),
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Color(0xFFA44AFF)),
                        labelText: 'Userame',
                        labelStyle: TextStyle(color: Color(0xFFA44AFF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
                    child: TextField(
                      controller: _emailController..text = userData!.email,
                      style: const TextStyle(color: Colors.white),
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFFA44AFF)),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFFA44AFF)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushNamed(context, "/login");
                      showToast(message: "Successfully signed out");
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
    );
  }
}