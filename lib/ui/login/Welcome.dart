import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/ui/login/login.dart';

import 'signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [Colors.white, Color(0xFFFCE8EB)];
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height:
                    screenHeight * 0.1), // Adjusted spacing for responsiveness
            Image.asset('assets/Frame 37-3.png',
                height: screenHeight *
                    0.55), // Adjusted image size for responsiveness

            SizedBox(height: screenHeight * 0.1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return signinPage();
                    }));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.white24), // Border color
                      ),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight *
                            0.020), // Adjusted padding for responsiveness
                    child: Text(
                      'Sign up',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(
                    width: screenWidth *
                        0.1), // Adjusted spacing for responsiveness

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }));
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red), // Border color
                      ),
                    ),
                    elevation: MaterialStateProperty.all(0),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight *
                            0.020), // Adjusted padding for responsiveness
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
