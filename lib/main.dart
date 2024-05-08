import 'dart:io';

import 'package:chemgital/pages/App/comment_page.dart';
import 'package:chemgital/pages/App/create_forum.dart';
import 'package:chemgital/pages/App/exercise_page.dart';
import 'package:chemgital/pages/App/home_screen.dart';
import 'package:chemgital/pages/App/forum_page.dart';
import 'package:chemgital/pages/App/quiz/quiz_page.dart';
import 'package:chemgital/pages/App/quiz/score_screen.dart';
import 'package:chemgital/pages/App/splash_screen.dart';
import 'package:chemgital/pages/App/upload_exercise.dart';
import 'package:chemgital/pages/Auth/login_page.dart';
import 'package:chemgital/pages/App/notes_page.dart';
import 'package:chemgital/services/exercise_service.dart';
import 'package:chemgital/services/forum_service.dart';
import 'package:chemgital/services/pdf_service.dart';
import 'package:chemgital/services/quiz_controller.dart';
import 'package:chemgital/services/quiz_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  Platform.isAndroid 
    ? await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyAFsTJe1JuZakwAkq5hvVcz-k2p6gIcTvY', 
          appId: '1:655216633887:android:d033ab685699ca68fa8d2a', 
          messagingSenderId: '655216633887', 
          projectId: 'chemgital-2c462',
          storageBucket: 'gs://chemgital-2c462.appspot.com',
          )
      ) 
    
    : await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PdfService()),
        ChangeNotifierProvider(create: (context) => ForumsService()),
        ChangeNotifierProvider(create: (context) => ExerciseService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => const LoginPage(),
        '/notes': (context) => NotesPage(),
        '/rooms': (context) => Forum(),
        '/create_forum': (context) => const CreateForum(),
        '/exercise' : (context) => ExercisePage(),
        '/quiz': (context) => QuizPage(),
        'upload_exercise': (context) => const UploadExercise(),
      },
      home: const SplashScreen(),
    );
  }
}

