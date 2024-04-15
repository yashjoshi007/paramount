import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:paramount/ui/login/login.dart';
import 'package:paramount/ui/screens/homeScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
        apiKey: "AIzaSyBHllZOMZfToChdpgLDEBfluUFna05GQGI",
        appId: "1:9347458572:android:d6c1e8bca44c5c7d1f7029",
        messagingSenderId: "9347458572",
        projectId: "paramount-4b774",
      ),
    );
  } 
  else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            return MyHomePage(); // Navigate to home screen if user is logged in
          } else {
            return LoginPage(); // Otherwise, navigate to login screen
          }
        },
      ),
    );
  }
}
