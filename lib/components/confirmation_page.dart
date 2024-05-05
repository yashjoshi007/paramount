import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/ui/screens/homeScreen.dart';

import '../ui/login/login.dart';
import '../ui/screens/homeColleague.dart';

class ConfirmPage extends StatelessWidget {
  final String description;
  final String btnText;

  ConfirmPage({ required this.description, required this.btnText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
               'assets/mail3.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 25),
              Text(
                'Check your mail',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 15),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        child:Column(
          children: [
            ElevatedButton(
              onPressed: () async{
                if (description == "Mail has been successfully sent to PJC.")
                  {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) {
                      return HomePageColleague(userRole: '',);
                    }));
                  }
                else if(description == "Mail has been successfully sent to PJC and your account."){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) {
                    return HomePageClient(userRole: '',);
                  }));
                }
                else {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.red), // Border color
                  ),
                ),
                shadowColor: MaterialStateProperty.all(Colors.orange.withOpacity(0.5)),
                elevation: MaterialStateProperty.all(5), // Adjust elevation as needed
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set to 40% of the screen width
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  btnText,
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
      ),
    );
  }
}
