import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/textField.dart';
import '../../models/user_model.dart';
import '../screens/homeScreen.dart';
// import 'forgotPwd.dart';
import 'login.dart';

class signinPage extends StatefulWidget {
  const signinPage({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<signinPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Create a GlobalKey
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController compNameController = new TextEditingController();
  bool isLoading = false;

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children:[ SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Images at the top
                  Center(child: Image.asset('assets/logo.png', width: 150, height: 150)),
                  SizedBox(height: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Welcome!',
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Create a new account with PMT-TXT',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey, // Assign the GlobalKey to Form
                      child: Column(
                        children: [
                          MyTextField(
                            hintText: 'Name',
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              nameController.text = value!;
                            },
                            keyboardType: TextInputType.text, controller: nameController,
                          ),// Name
                          SizedBox(height: 20),
                          MyTextField(
                            hintText: 'Company Name',
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your company name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              compNameController.text = value!;
                            },
                            keyboardType: TextInputType.text, controller: compNameController,
                          ),// Company Name
                          SizedBox(height: 20),
                          MyTextField(
                            hintText: 'Email',
                            validator: (value) {
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
                              emailController.text = value!;
                            },
                            keyboardType: TextInputType.emailAddress, controller: emailController, obscureText: false,
                          ),// Email
                          SizedBox(height: 20),
                          MyTextField(
                            hintText: 'Password',
                            obscureText: true,
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Password is required for login";
                              }
                              if (!regex.hasMatch(value)) {
                                return "Enter Valid Password (Min. 6 Characters)";
                              }
                              return null; // Return null if the password is valid
                            },
                            onSaved: (value) {
                              passwordController.text = value!;
                            },
                            keyboardType: TextInputType.text, controller: passwordController,
                          ), // Password
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
              if (isLoading)
                Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.red,
                    radius: 20,
                    animating: true,
                  ),
                ),
          ]),
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          height: 120,
          child: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Already have an account? ", style: GoogleFonts.poppins(),),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context){
                          return LoginPage();}));
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 15),
                      ),
                    )
                  ]),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    setState(() {
                      isLoading = true; // Start showing loader
                    });
                  await signUp(emailController.text, passwordController.text);
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
                    'Create new account',
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

  postDetailsToFirestore() async {


    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = nameController.text;
    userModel.companyName = compNameController.text;
    userModel.role = "Customer";


    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());

    Navigator.push(
      context, MaterialPageRoute(builder: (context){
      return HomePageClient(userRole: "Customer",);
    },
    ),
    );


  }

  Future<void> signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim())
          .then((value) => {postDetailsToFirestore()})

          // ignore: body_might_complete_normally_catch_error
          .catchError((e) {
        print("Error: $e");
        setState(() {
          isLoading = false;
        });
      });
    }
  }


}
