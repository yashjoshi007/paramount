import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paramount/ui/login/Welcome.dart';
import 'package:paramount/ui/login/login.dart';
import 'package:paramount/ui/screens/homeColleague.dart';
import 'package:paramount/ui/screens/homeScreen.dart';
import 'package:provider/provider.dart';
import 'localization/language_provider.dart';

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
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                LanguageProvider()), // Replace LanguageProvider with your actual provider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sample Selector',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
        ),
        // home: SplashScreen(),
        home: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SplashScreen(); // Use SplashScreen while waiting
            } else if (snapshot.hasData && snapshot.data != null) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SplashScreen(); // Use SplashScreen while waiting
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data != null) {
                    // Get user role from Firestore
                    String role = userSnapshot.data!['role'];
                    print(role);
                    if (role == 'colleague' || role == 'Colleague') {
                      return HomePageColleague(
                        userRole: role,
                      ); // Navigate to colleague home screen
                    } else if (role == 'customer' || role == 'Customer') {
                      return HomePageClient(
                        userRole: role,
                      ); // Navigate to user home screen
                    } else {
                      return LoginPage();
                    }
                  } else {
                    return LoginPage(); // Navigate to login screen if user data is not available
                  }
                },
              );
            } else {
              return WelcomeScreen(); // Navigate to login screen if user is not logged in
            }
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Image.asset('assets/logo.png', width: 150, height: 150)),
            SizedBox(height: 20),
            CupertinoActivityIndicator(
              color: Colors.red,
              radius: 20,
              animating: true,
            ),
          ],
        ),
      ),
    );
  }
}
