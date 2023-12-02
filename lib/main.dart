import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projecttwo/homescreen.dart';
import 'package:projecttwo/splashscreen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: splashscreen(),
      routes: {
        '/homescreen': (context) => homescreen(),
      },
    );
  }
}
