import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:paramount/ui/screens/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/login/login.dart';
import '../ui/screens/homeColleague.dart';

class ConfirmPage2 extends StatefulWidget {
  final String description;
  final String btnText;
  final String userRole;

  ConfirmPage2({required this.description, required this.btnText, required this.userRole});

  @override
  _ConfirmPage2State createState() => _ConfirmPage2State();
}

class _ConfirmPage2State extends State<ConfirmPage2> {
  String Email = '';
  List<Map<String, String>> _barcodeList = [];

  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
  }

  _loadBarcodeList() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? barcodeListString = prefs.getStringList('barcodeList');
      if (barcodeListString != null) {
        setState(() {
          _barcodeList = barcodeListString
              .map<Map<String, String>>(
                  (item) => Map<String, String>.from(json.decode(item)))
              .toList();
        });
        _barcodeList.forEach((barcode) {
          print('Barcode: ${barcode['barcode']}, Name: ${barcode['quantity']}');
          print(widget.userRole);
          // Add other properties if available
        });
      }
  }

  Future<Map<String, dynamic>> loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('userDetails');
    if (userDetailsString != null) {
      Map<String, dynamic> userDetails = json.decode(userDetailsString);
      return userDetails;
    } else {
      return {};
    }
  }


  _clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userDetails');
  }

  Future<void> doPostRequestCustomer(BuildContext context) async {
    // URL of your Google Apps Script web app
    String scriptUrl =
        'https://script.google.com/macros/s/AKfycbyd6aJmcHBHy10jRtZmHgWra5cMvJjiGhuzpL_asQQEgli1EB0AXt4eeuD26JtOypp6/exec';

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;
        String email = userData['email'];
        String name = userData['name'];
        String companyName = userData['companyName'];
        String role = userData['role'];
        Email = email;


        // Constructing requestData
        Map<String, dynamic> requestData = {
          'Customer_Email': email,
          'Customer_Name': name,
          'Company_Name': companyName,
          'total_Samples': _barcodeList.length,
        };

        // Adding barcode data dynamically
        for (int i = 0; i < _barcodeList.length; i++) {
          requestData['Article ${i + 1}'] = _barcodeList[i]['barcode'];
          requestData['Qty ${i + 1}'] = _barcodeList[i]['quantity'];
        }

        // Sending POST request to the Google Apps Script web app
        var response = await http.post(
          Uri.parse(scriptUrl),
          body: json.encode(requestData),
        );

        // Checking the response
        if (response.statusCode == 200 || response.statusCode == 302) {
          print('Request successful: ${response.body}');
          await _clearBarcodeList();
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> doPostRequestColleague(BuildContext context) async {
    // URL of your Google Apps Script web app
    String scriptUrl = 'https://script.google.com/macros/s/AKfycbyd6aJmcHBHy10jRtZmHgWra5cMvJjiGhuzpL_asQQEgli1EB0AXt4eeuD26JtOypp6/exec';
    print("emails");
    try {
      // Load user details
      Map<String, dynamic> userDetails = await loadUserDetails();
      if (userDetails.isEmpty) {
        print('User details not found.');
        return; // Exit the function if user details are not available
      }
      Email = userDetails['email'];
      // Load barcode list
      _loadBarcodeList();
      print("data");
      print(userDetails['email']);
      // Assuming this function updates _barcodeList
      print("EM - $Email");
      // Constructing requestData
      Map<String, dynamic> requestData = {
        'Customer_Email': userDetails['email'],
        'Customer_Name': userDetails['name'],
        'Company_Name': userDetails['companyName'],
        'total_Samples': _barcodeList.length,
      };


      // Adding barcode data dynamically
      for (int i = 0; i < _barcodeList.length; i++) {
        requestData['Article ${i + 1}'] = _barcodeList[i]['barcode'];
        requestData['Qty ${i + 1}'] = _barcodeList[i]['quantity'];
      }

      // Sending POST request to the Google Apps Script web app
      var response = await http.post(
        Uri.parse(scriptUrl),
        body: json.encode(requestData),
      );

      // Checking the response
      if (response.statusCode == 200 || response.statusCode == 302) {
        print('Request successful: ${response.body}');

        // Clear user details and barcode list
        await _clearUserDetails();
        await _clearBarcodeList();
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void sendEmails(String recipient, String subject, List<Map<String, String>> barcodeList, {required List<String> cc}) async {
    // Construct the email body
    String body = 'Your order is -\n';

    // Append each barcode to the body
    barcodeList.forEach((barcode) {
      body += 'Barcode: ${barcode['barcode']}, Name: ${barcode['quantity']}\n';
      // Add other properties if available
    });

    // Construct the email URI
    String uri = 'mailto:$recipient';

    if (cc.isNotEmpty) {
      uri += '?cc=${cc.join(",")}';
    }

    uri += '&subject=$subject&body=${Uri.encodeComponent(body)}';

    // Check if the device can send emails
    if (await canLaunch(uri)) {
      // Launch the email client
      await launch(uri);
    } else {
      // If the device cannot send emails, show an error message
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async{
            await _clearBarcodeList();
            await _clearUserDetails();
            Navigator.pop(context,true);
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
                widget.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_barcodeList.length != 0) {
                  print("exed");
                  if(widget.userRole=="customer") {
                    doPostRequestCustomer(context);
                  }else if(widget.userRole=="colleague"){
                    doPostRequestColleague(context);

                  }
                  print("esec");
                  print("EM- $Email");
                  sendEmails('yashjoshi1105@gmail.com', 'HI', _barcodeList,
                      cc: [Email]);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No barcodes are available.'),
                    ),
                  );
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
                shadowColor: MaterialStateProperty.all(
                    Colors.orange.withOpacity(0.5)),
                elevation: MaterialStateProperty.all(5), // Adjust elevation as needed
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.6, // Set to 40% of the screen width
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  widget.btnText,
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

  Future<void> _clearBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('barcodeList');
    setState(() {
      _barcodeList.clear();
    });
  }
}
