
import 'package:chemgital/pages/Auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chemgital/pages/App/home_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    Future<void> delayedFunction() async {
      await Future.delayed(const Duration(seconds: 3));
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }

    delayedFunction();
    
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
              color: Color(0xFF040C23)),
        ),
        Center(
          child: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 42,
              ),
              SvgPicture.asset(
                'assets/svg/CHEMGITAL.svg',
                height: 300,
              ),
              const SizedBox(
                height: 73,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "Helping you\nto learn ",
                      style: GoogleFonts.manrope(
                          fontSize: 24,
                          color: const Color(0xFFDEE1FE),
                          letterSpacing: 3.5 / 100,
                          height: 152 / 100),
                      children: const [
                        TextSpan(
                            text: "Chemistry",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                        TextSpan(text: "\neveryday!")
                      ]))
            ],
          )),
        )
      ]),
    );
  }
}