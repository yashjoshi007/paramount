import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:paramount/ui/screens/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../localization/language_provider.dart';

class ConfirmPage2 extends StatefulWidget {
  final String description;
  final String btnText;
  final String userRole;
  final String Email;

  ConfirmPage2({required this.description, required this.btnText, required this.userRole,required this.Email});

  @override
  _ConfirmPage2State createState() => _ConfirmPage2State();
}

class _ConfirmPage2State extends State<ConfirmPage2> {
  String Email = '';
  List<Map<String, String>> _barcodeList = [];
  var date_time;

  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
  }

  _setDateTime(){
    date_time = DateTime.now();
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
          print('Barcode: ${barcode['barcode']}, Quantity: ${barcode['quantity']}, Unit: ${barcode['unit']}');
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
        'https://script.google.com/macros/s/AKfycbz-76mK3HfLEpY2S3Q66GeFrO6Utq82mgyiYH8cccXoEkByXuQSbjDFa8n1ftIL28KY/exec';

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
        // ignore: unused_local_variable
        String role = userData['role'];
        Email = email;

        _setDateTime();

        // Constructing requestData
        Map<String, dynamic> requestData = {
          'date': date_time.toString(),
          'Sample_picker': name,
          'Customer_Email': email,
          'Customer_Name': name,
          'Company_Name': companyName,
          'total_Samples': _barcodeList.length,
        };

        // Adding barcode data dynamically
        for (int i = 0; i < _barcodeList.length; i++) {
          requestData['Article ${i + 1}'] = _barcodeList[i]['barcode'];
          requestData['Qty ${i + 1}'] = _barcodeList[i]['quantity'];
          requestData['Unit ${i + 1}'] = _barcodeList[i]['unit'];
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
    String scriptUrl =
        'https://script.google.com/macros/s/AKfycbz-76mK3HfLEpY2S3Q66GeFrO6Utq82mgyiYH8cccXoEkByXuQSbjDFa8n1ftIL28KY/exec';

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
      // print("data");
      // print(userDetails['email']);
      // // Assuming this function updates _barcodeList
      // print("EM - $Email");
      // Constructing requestData
      String pickerName = '';
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> appUser = userSnapshot.data() as Map<String, dynamic>;
        pickerName = appUser['name'];
      }
      _setDateTime();

      Map<String, dynamic> requestData = {
        'date': date_time.toString(),
        'Sample_picker': pickerName,
        'Customer_Email': userDetails['email'],
        'Customer_Name': userDetails['name'],
        'Company_Name': userDetails['companyName'],
        'total_Samples': _barcodeList.length,
      };

      // Adding barcode data dynamically
      for (int i = 0; i < _barcodeList.length; i++) {
        requestData['Article ${i + 1}'] = _barcodeList[i]['barcode'];
        requestData['Qty ${i + 1}'] = _barcodeList[i]['quantity'];
        requestData['Unit ${i + 1}'] = _barcodeList[i]['unit'];
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

  void sendEmailCustomer(String recipient, String subject, List<Map<String, String>> barcodeList, {required List<String> cc}) async {
    String custemail = '';
    String custname = '';
    User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> appUser = userSnapshot.data() as Map<String, dynamic>;
        custemail = appUser['email'];
        custname = appUser['name'];
      }
    
    // Construct the email body
      String body = '''Dear Paramount Team,\nI have selected samples from your booth with below items, Please prepare the samples as soon as possible. \n\n------------------------------\n\n''';

    // Append each barcode to the body
    barcodeList.forEach((barcode) {
      body += 'Article No.: ${barcode['barcode']}' '\n';
      body += 'QTY: ${barcode['quantity']}' '\n';
      body += 'Unit: ${barcode['unit']}' '\n\n';
    });

    body += '''------------------------------\n\nBest regards,\n''';
    body += custname;

    // Construct the email URI
    String uri = 'mailto:$recipient';
    cc.add(custemail);

    if (cc.isNotEmpty) {
      uri += '?cc=${cc.join(",")}';
    }

    uri += '&subject=$subject&body=${body}';

    // Check if the device can send emails
    if (await canLaunchUrlString(uri)) {
      // Launch the email client
      await launchUrlString(uri);
    } else {
      // If the device cannot send emails, show an error message
      throw 'Could not launch email';
    }
  }

  void sendEmailColleague(String recipient, String subject, List<Map<String, String>> barcodeList, {required List<String> cc}) async {
    // Construct the email body
      String body = '''Dear Madam/Sir,\nThanks for your visiting our booth, you have selected samples from our booth with below items, we would like to list the items herewith, we will prepare them as soon as possible, my colleague will update you asap. \n\n------------------------------\n\n''';

    // Append each barcode to the body
    barcodeList.forEach((barcode) {
      body += 'Article No.: ${barcode['barcode']}' '\n';
      body += 'QTY: ${barcode['quantity']}' '\n';
      body += 'Unit: ${barcode['unit']}' '\n\n';
    });

    body += '''------------------------------\n\nBest regards,\n\nAuto email sent from Paramount Server, No need to reply this email.
 ''';

    // Construct the email URI
    String uri = 'mailto:$recipient';

    if (cc.isNotEmpty) {
      uri += '?cc=${cc.join(",")}';
    }

    uri += '&subject=$subject&body=${body}';

    // Check if the device can send emails
    if (await canLaunchUrlString(uri)) {
      // Launch the email client
      await launchUrlString(uri);
    } else {
      // If the device cannot send emails, show an error message
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async{
            if(_barcodeList.length==0){
            _clearUserDetails();
            _clearBarcodeList();
            Navigator.pop(context,true);}
            else{
              Navigator.pop(context,false);
            }
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
                languageProvider.translate('want_email'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
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
        height: 160,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_barcodeList.isNotEmpty) {
                  if(widget.userRole=="customer" || widget.userRole=="Customer") {
                    doPostRequestCustomer(context);
                    sendEmailCustomer('Fair.sample@paramountex.com', 'Selected Samples List', _barcodeList,
                      cc: [widget.Email]);
                  }else if(widget.userRole=="colleague" || widget.userRole=="Colleague"){
                    doPostRequestColleague(context);
                    sendEmailColleague(widget.Email, 'Selected Samples List', _barcodeList,
                      cc: ['Fair.sample@paramountex.com']);
                  }
                  
                  // print(widget.Email);
                  // sendEmails('patricktse100@gmail.com', 'Selected Samples List', _barcodeList,
                  //     cc: [widget.Email]);
                  Navigator.pop(context,true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No barcodes are available.'),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFF4F1F1)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    // side: BorderSide(color: Colors.red), // Border color
                  ),
                ),
                // shadowColor: MaterialStateProperty.all(
                //     Colors.orange.withOpacity(0.5)),
                elevation: MaterialStateProperty.all(0), // Adjust elevation as needed
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.75, // Set to 40% of the screen width
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  widget.btnText,
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
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_barcodeList.isNotEmpty) {
                  if(widget.userRole=="customer" || widget.userRole=="Customer") {
                    doPostRequestCustomer(context);
                    
                  }else if(widget.userRole=="colleague" || widget.userRole=="Colleague"){
                    doPostRequestColleague(context);
                    
                  }
                  Navigator.pop(context,true);
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
                    // side: BorderSide(color: Colors.red), // Border color
                  ),
                ),
                // shadowColor: MaterialStateProperty.all(
                //     Colors.orange.withOpacity(0.5)),
                elevation: MaterialStateProperty.all(0), // Adjust elevation as needed
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.75, // Set to 40% of the screen width
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "List Saved, Click to go back",
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
