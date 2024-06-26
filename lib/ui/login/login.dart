import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/ui/login/signup.dart';
import 'package:paramount/ui/screens/homeScreen.dart';

import '../../components/textField.dart';
import '../screens/homeColleague.dart';
import 'forgotPwd.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Create a GlobalKey
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.0), // Added top padding
                  child: Center(child: Image.asset('assets/logo.png', width: 150, height: 150)),
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Log In with your username or email',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: 120), // Adjust the left padding as needed
                //   child: Text(
                //     'for HCE\'s', // Add your additional text here
                //     style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange),
                //   ),
                // ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey, // Assign the GlobalKey to Form
                    child: Column(
                      children: [
                        MyTextField(
                          hintText: 'Email',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress, controller: emailController, obscureText: false,
                        ),
                        SizedBox(height: 20),
                        MyTextField(
                          hintText: 'Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.text, controller: passwordController,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context, MaterialPageRoute(builder: (context){
                                    return ForgotPassword();
                                  },
                                  ),
                                  );
                                },
                
                                child: Text('Forgot Password ?',
                                  style: GoogleFonts.poppins(color: Colors.red),),
                              )],
                          ),
                        ),
                
                        SizedBox(height: 20),
                
                        // Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: <Widget>[
                        //       Text("Don't have an account? ", style: GoogleFonts.poppins(),),
                        //       GestureDetector(
                        //         onTap: () {
                        //           Navigator.push(
                        //               context, MaterialPageRoute(builder: (context){
                        //             return signinPage();}));
                        //         },
                        //         child: Text(
                        //           "Sign Up",
                        //           style: GoogleFonts.poppins(
                        //               color: Colors.red,
                        //               fontSize: 15),
                        //         ),
                        //       )
                        //     ]),
                        // SizedBox(height: 10),
                        // // Login Button
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Validate the form
                        //     print(emailController.text);
                        //     print(passwordController.text);
                        //     if (_formKey.currentState!.validate()) {
                        //       _formKey.currentState!.save();
                        //       signIn(emailController.text, passwordController.text);
                
                        //     }
                        //   },
                        //   style: ButtonStyle(
                        //     backgroundColor: MaterialStateProperty.all(Colors.red),
                        //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        //       RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //         side: BorderSide(color: Colors.red), // Border color
                        //       ),
                        //     ),
                        //     shadowColor: MaterialStateProperty.all(Colors.orange.withOpacity(0.5)),
                        //     elevation: MaterialStateProperty.all(5), // Adjust elevation as needed
                        //   ),
                        //   child: Container(
                        //     width: double.infinity,
                        //     padding: EdgeInsets.symmetric(vertical: 15),
                        //     child: Text(
                        //       'Login',
                        //       style: GoogleFonts.poppins(
                        //         color: Colors.white,
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.w400,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                _loading
                    ? Center(
                  child:  CupertinoActivityIndicator(
                    color: Colors.red,
                    radius: 20,
                    animating: true,
                  ),
                )
                    : SizedBox()
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 120,
          child: Column(
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Don't have an account? ", style: GoogleFonts.poppins(),),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context){
                          return signinPage();}));
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 15),
                      ),
                    )
                  ]),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    signIn(emailController.text, passwordController.text);
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
        ),
      ),
    );
  }

  Future<void> signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _loading = true;
        });

        final userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        print("User authenticated successfully!");

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        print("User document retrieved successfully!");

        // Extract role from user document
        final userRole = userDoc['role'];
        print("User role: $userRole");


        setState(() {
          _loading = false;
        });
        // Navigate based on user role
        if (userRole == 'customer' || userRole == 'Customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePageClient(userRole: userRole,)),
          );
        } else if (userRole == 'colleague' || userRole == 'Colleague') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePageColleague(userRole: userRole,)),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException
        print("FirebaseAuthException occurred: ${e.code}");
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
              msg: "No user found for that email",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
              msg: "Wrong password provided for that user",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        } else if (e.code == 'invalid-email') {
          Fluttertoast.showToast(
              msg: "Invalid email format",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: e.message!,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.grey[600],
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    }
  }

}
