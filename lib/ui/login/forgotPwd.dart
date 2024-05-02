
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/confirmation_page.dart';
import 'package:paramount/components/myBtn.dart';

import '../../components/textField.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController email1Controller = new TextEditingController();
  @override
  void dispose(){
    email1Controller.dispose();
    super.dispose();

  }

  Future passwordReset() async{
    print(email1Controller.text);
    try{
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email1Controller.text.trim());
      showDialog(
          context: context,
          builder: (context)
          {
            return ConfirmPage(description: 'We have sent a password recovery instructions to your mail.',);

          });

    }
    on FirebaseException catch(e)
    {
      print(e);
      showDialog(
          context: context,
          builder: (context)
          {
            return AlertDialog(
              content: Text(e.message.toString()),
            );

          });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Reset Password',
                    style: GoogleFonts.poppins( fontSize:20, fontWeight: FontWeight.w600,),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Enter the email associated with the account and we’ll send an email with instructions to reset your password.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins()),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 100.0,
                          width: 100.0,
                          child: Image.asset('assets/mail3.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12,8,12,8),
                  child: MyTextField(
                    controller: email1Controller, hintText: "Enter Email", validator: (value) {
                    if (value!.isEmpty) {
                      return ("Please Enter Your Email");
                    }
                    // reg expression for email validation
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return ("Please Enter a valid email");
                    }
                    return null;
                  },
                    onSaved: (value) {
                      email1Controller.text = value!;
                    },  obscureText: false, keyboardType: TextInputType.emailAddress,  ),
                ),
                // SizedBox(height: 30,),
                // RectangularButton(text: "Send Instructions", color: Colors.red,
                //     onPressed: () {
                //       if (_formKey.currentState!.validate()) {
                //         _formKey.currentState!.save();
                //         passwordReset();
                //       }
            
            
                // }, btnText: Colors.white)
            
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          height: 90,
          child: Column(
            children: [
                
              
              ElevatedButton(
                onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        passwordReset();
                      }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red), // Border color
                    ),
                  ),
                  // shadowColor: MaterialStateProperty.all(Colors.orange.withOpacity(0.5)),
                  elevation: MaterialStateProperty.all(0), // Adjust elevation as needed
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75, // Set to 40% of the screen width
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Send Instructions',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),),
    );
  }
}
