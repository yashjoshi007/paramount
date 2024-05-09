import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_pro_barcode_scanner/flutter_pro_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/confirmation_page.dart';
import '../../components/confirmpage2.dart';
import '../../components/textField.dart';
import '../../localization/language_provider.dart';
import '../login/login.dart';
import 'articleDetailScreen.dart';
import 'package:http/http.dart' as http;



class HomePageColleague extends StatefulWidget {
  final String userRole;
  const HomePageColleague({Key? key, required this.userRole}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageColleague> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedLanguage = 'en';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> _barcodeList = [];
  String _scanBarcodeResult = "";
  bool showBottom = false ;

  Future<void> signOutGoogle() async {
    await _clearUserDetails();
    await _clearBarcodeList();
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
   // _clearUserDetails(); // Clear user details on app start
    _loadBarcodeList();
    _checkUserDetails();
  }

  _clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userDetails');
  }

  _clearBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('barcodeList');
  }

  _loadBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? barcodeListString = prefs.getStringList('barcodeList');
    if (barcodeListString != null) {
      setState(() {
        _barcodeList = barcodeListString.map<Map<String, String>>((item) => Map<String, String>.from(json.decode(item))).toList();
      });
      _barcodeList.forEach((barcode) {
        print('Barcode: ${barcode['barcode']}, Name: ${barcode['quantity']}');
        // Add other properties if available
      });
    }
  }

  _saveBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList = _barcodeList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('barcodeList', encodedList);
  }

  // newBarcodeScan() {
  //   QrBarCodeScannerDialog().getScannedQrBarCode(
  //   context: context,
  //   onCode: (res) {
  //     setState(() {
  //       if (res is String && res != '') {
  //         _scanBarcodeResult = res;
  //         if(!_barcodeList.contains({'barcode': _scanBarcodeResult})){
  //           _barcodeList.insert(0,{'barcode': _scanBarcodeResult, 'quantity': '1'});
  //           _saveBarcodeList();
  //         }
  //         else{
  //           ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Barcode Already Scanned!'),
  //           ),
  //         );
  //         }
  //       } else if(res == "-1") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Try again to scan a barcode.'),
  //           ),
  //         );
  //       }
  //     });
      
  //   });
  // }

  // Future<void> scanBarcodeNormal() async {
  //   String barcodeScanRes;
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Done', true, ScanMode.BARCODE);
  //     print(barcodeScanRes);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   if (barcodeScanRes.length == 8 || barcodeScanRes.length == 9) {
  //     if (!mounted) return;
  //     setState(() {
  //       _scanBarcodeResult = barcodeScanRes;
  //       _barcodeList.add({'barcode': barcodeScanRes, 'quantity': "1"});
  //       _saveBarcodeList();
  //     });
  //   } else if(barcodeScanRes == "-1") {
  //     // Show snackbar if barcode length is not 8 or 9
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Try again to scan a barcode.'),
  //       ),
  //     );
  //   }
  //   else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Scan Barcode Properly.'),
  //       ),
  //     );
  //   }
  // }

  void removeBarcode(int index) {
    setState(() {
      _barcodeList.removeAt(index);
      _saveBarcodeList();
    });
  }

  Future<void> saveUserDetails(String name, String companyName, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userDetails = {
      'name': name,
      'companyName': companyName,
      'email': email,
    };
    await prefs.setString('userDetails', json.encode(userDetails));
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

  Future _checkUserDetails() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDetailsString = prefs.getString('userDetails');
    if (userDetailsString != null) {
      setState(() {
        showBottom = true;
      });
    } else {
      setState(() {
        showBottom = false;
      });

    }
  }

  void _fetchArticleDetails(String barcode) async {
    bool snackbarShown = false; // Flag to track whether a Snackbar is shown

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing when tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Adjust border radius as needed
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CupertinoActivityIndicator(
                  color: Colors.red,
                  radius: 20,
                  animating: true,
                ),
              ),
              SizedBox(height: 50), // Add some space between CircularProgressIndicator and the text
              Text(
                'Loading Article Details...', // Add your desired text here
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
    //  String apiUrl = 'https://script.googleusercontent.com/macros/echo?user_content_key=TDlb7rLM_rqiKYr72gebRVN0s-zVy74koY7tSPXgNt9y7MfOFmAsNEyqmemyJ-W35pPtyav9mVDiUy6QNPb9KChUStuwIoOim5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnHJ5yWFXmy7bGcFeDpHjdWgQ9vetL1X7__qJJSutHRKFd77SxtRRlYq3GttY1ADGP43MM7kX-KfDHzPnPB8uoh1aDoUU23LwIQ&lib=MIc7FXjH6n7WaW-Iw0K14H0X2Nb-b482m';
    // Replace this URL with your actual Google Sheets API endpoint
    String apiUrl = 'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getArticleColleague&articleNumber=$barcode';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var article = data['data'];
        if (article != null && article.isNotEmpty) {
          var articleDetails = article[barcode];
          if (articleDetails != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailsPage(
                  articleDetails: articleDetails,
                  userRole: widget.userRole,
                  barcode: barcode,
                ),
              ),
            ).then((_) {
              if (!snackbarShown) {
                Navigator.pop(context);
              }
            });
            return;
          }
        }


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Article not found',
              style: TextStyle(fontFamily: 'GoogleFonts.poppins'),
            ),
          ),
        );
        snackbarShown = true;
        Navigator.pop(context);
      } else {
        // If the server returns an error response, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load article details',style: GoogleFonts.poppins())));
        snackbarShown = true;
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error fetching article details: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching article details',style: GoogleFonts.poppins())));
      snackbarShown = true;
      Navigator.pop(context);
    }
  }


  // void sendEmails(String recipient, String subject, String body, {required List<String> cc, required List<String> bcc}) async {
  //   // Construct the email URI
  //   String uri = 'mailto:$recipient';
  //
  //   if (cc != null && cc.isNotEmpty) {
  //     uri += '?cc=${cc.join(",")}';
  //   }
  //
  //   if (bcc != null && bcc.isNotEmpty) {
  //     uri += '&bcc=${bcc.join(",")}';
  //   }
  //
  //   uri += '&subject=$subject&body=$body';
  //
  //   // Check if the device can send emails
  //   if (await canLaunch(uri)) {
  //     // Launch the email client
  //     await launch(uri);
  //   } else {
  //     // If the device cannot send emails, show an error message
  //     throw 'Could not launch email';
  //   }
  // }

  Future<void> doPostRequest(BuildContext context) async {
    // URL of your Google Apps Script web app
    String scriptUrl = 'https://script.google.com/macros/s/AKfycbyd6aJmcHBHy10jRtZmHgWra5cMvJjiGhuzpL_asQQEgli1EB0AXt4eeuD26JtOypp6/exec';

    try {
      // Load user details
      Map<String, dynamic> userDetails = await loadUserDetails();
      if (userDetails.isEmpty) {
        print('User details not found.');
        return; // Exit the function if user details are not available
      }

      // Load barcode list
      _loadBarcodeList(); // Assuming this function updates _barcodeList

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
        // Navigate to another page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPage(description: 'Mail has been successfully sent to PJC.',btnText: "Send",),
          ),
        );

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



  void _addArticleManually(String articleNo, int quantity) {
    setState(() {
      _barcodeList.insert(0,{'barcode': articleNo, 'quantity': quantity.toString()});
      _saveBarcodeList();
    });
  }

  void showAddArticleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return addArticleDialog(context);
      },
    );
  }

  Widget addArticleDialog(BuildContext context) {
    String articleNo = "";
    String quantity = "";

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6), // Adjust border radius as needed
      ),
      title: Text(
        "Add Article Manually",
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                articleNo = value;
              },
              decoration: InputDecoration(
                labelText: 'Article No.',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                quantity = value;
              },
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 20), // Add padding to actions
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), // Adjust border radius as needed
                  color: Color(0xFFF4F1F1), // Set the background color
                ),
                child: TextButton(
                  onPressed: () {
                    _addArticleManually(articleNo, int.parse(quantity)); // Add article manually
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // Adjust button padding
                  ),
                  child: Text(
                    'Add',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red, // Set text color
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10), // Add spacing between buttons
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Adjust button padding
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );


  }


  // void sendEmail(String recipient, String subject, String body) async {
  //   final emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  //
  //   // Replace these values with your EmailJS service ID and template ID
  //   final serviceId = 'service_s0bpub7';
  //   final templateId = 'template_22ev90g';
  //
  //   // Construct the request body
  //   final requestBody = {
  //     'service_id': serviceId,
  //     'template_id': templateId,
  //     'user_id': 'bOirGg6PsenrVhRpr',
  //     'template_params': {
  //       'to_email': recipient,
  //       'subject': subject,
  //       'body': body,
  //     },
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(emailJsApiUrl),
  //       headers: {
  //         'origin': 'http://localhost',
  //         'Content-Type': 'application/json'},
  //       body: json.encode(requestBody),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Email sent successfully!');
  //     } else {
  //       print('Failed to send email. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error sending email: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(child: Image.asset('assets/logo.png')),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/lang.png'),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          Row(
            children: [
              // IconButton(
              //   icon: Icon(Icons.delete), // Add delete icon
              //   onPressed: () async {
              //     setState(() {
              //       _nameController.text = ''; // Clear text fields
              //       _companyNameController.text = '';
              //       _emailController.text = '';
              //     });
              //     await _clearUserDetails();
              //   },
              // ),
              Text(
                languageProvider.translate('logout'),
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              IconButton(
                icon: Image.asset(
                  'assets/logout.png',
                  color: Colors.red,
                ),
                onPressed: () async {
                  signOutGoogle();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 110,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Text(
                  'Change Language',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            RadioListTile<String>(
              title: Text('English', style: GoogleFonts.poppins()),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
                Provider.of<LanguageProvider>(context, listen: false).setLanguage(_selectedLanguage!);
                Navigator.pop(context); // Close the drawer
              },
            ),
            RadioListTile<String>(
              title: Text('Chinese (Simplied)', style: GoogleFonts.poppins()),
              value: 'ch_si',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
                Provider.of<LanguageProvider>(context, listen: false).setLanguage(_selectedLanguage!);
                Navigator.pop(context); // Close the drawer
              },
            ),
            RadioListTile<String>(
              title: Text('Chinese (Traditional)', style: GoogleFonts.poppins()),
              value: 'ch_td',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value;
                });
                Provider.of<LanguageProvider>(context, listen: false).setLanguage(_selectedLanguage!);
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: loadUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator(
                color: Colors.red,
                radius: 20,
                animating: true,
              ),);
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic> userDetails = snapshot.data ?? {};
              bool userDetailsAvailable = userDetails.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!userDetailsAvailable) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        languageProvider.translate('details'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: languageProvider.translate('name'),
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _companyNameController,
                              decoration: InputDecoration(
                                labelText: languageProvider.translate('comp_name'),
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: languageProvider.translate('email'),
                                labelStyle: GoogleFonts.poppins(),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: RectangularICBtn(
                            onPressed: () async {
                              String name = _nameController.text;
                              String companyName = _companyNameController.text;
                              String email = _emailController.text;
            
                              if (name.isEmpty || companyName.isEmpty || email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all the details',style: GoogleFonts.poppins(),), // Prompt error message
                                  ),
                                );
                              } else {
                                await saveUserDetails(name, companyName, email);
                                setState(() {
                                  showBottom = true;
                                });
                              }
                            }, text: 'Add', iconAssetPath: "assets/plus.png", color: Color(0xFFF4F1F1), btnText: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  if (userDetailsAvailable) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        languageProvider.translate('customer_det'),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
            
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: RectangularICBtn(
                                      onPressed: () async {
                                      bool refresh = await  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmPage2(
                                                  description: 'Click "Send" and you will be redirected to your email app with automatically generated email.',
                                                  btnText: 'Send',
                                                  userRole: widget.userRole,
                                                  Email: '${userDetails['email']}',),
                                          ),
                                        );
                                      if(refresh==true)
                                        {
                                          setState(() {
                                            _barcodeList = [];
                                          });

                                        }
                                      }, text: languageProvider.translate('Save List'), iconAssetPath: "assets/mbox.png", color: Color(0xFFF4F1F1), btnText: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,10,0,5),
                                child: Text(
                                  '${languageProvider.translate('name')}: ${userDetails['name']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,10,0,10),
                                child: Text(
                                  '${languageProvider.translate('comp_name')}: ${userDetails['companyName']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,10,0,10),
                                child: Text(
                                  '${languageProvider.translate('email')}: ${userDetails['email']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/delete.png',
                            color: Colors.red,
                          ), // Add delete icon
                          onPressed: () async {
                            setState(() {
                              _nameController.text = ''; // Clear text fields
                              _companyNameController.text = '';
                              _emailController.text = '';
                              showBottom = false;
                            });
                            //await _clearBarcodeList();
                            await _clearUserDetails();

                          },
                        ),
                      ],
                    ),
                  ],
                  if (userDetailsAvailable)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        languageProvider.translate('Selected Samples'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  // Display sample list here
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0), // Add padding from left and right
                      child: ListView.builder(
                        itemCount: _barcodeList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Handle tap on the list tile
                              _fetchArticleDetails(_barcodeList[index]['barcode']!);
                            },
                            child: Card(
                              elevation: 0.0,
                              color: Color(0xFFF4F1F1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Display barcode and leading icon
                                    Expanded(
                                      flex: 2,
                                      child: ListTile(
                                        leading: Icon(Icons.qr_code),
                                        title: Text(
                                          '${languageProvider.translate('barcode')}: ${_barcodeList[index]['barcode']}',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                    ),
                                    // Display quantity input field
                                    Expanded(
                                      child: SizedBox(
                                        width: double.infinity, // Set width to occupy available space
                                        child: DelayedEditableTextField(
                                          value: _barcodeList[index]['quantity'].toString(),
                                          onChanged: (value) {
                                            _barcodeList[index]['quantity'] = value;
                                          },
                                          onEditingComplete: () {
                                            FocusScope.of(context).unfocus();
                                            // Save the updated list after a delay when editing is complete
                                            Future.delayed(Duration(milliseconds: 500), () {
                                              setState(() {
                                                _saveBarcodeList(); // Save the updated list
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    // Display delete icon
                                    IconButton(
                                      icon: Image.asset(
                                        'assets/delete.png',
                                        color: Colors.red,
                                      ),
                                      onPressed: () => removeBarcode(index),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
            
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: showBottom,
        child: BottomAppBar(
          surfaceTintColor: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RectangularIBtn(
                    onPressed: () {
                      showAddArticleDialog(context);
                    },
                    text: languageProvider.translate('Add Manually'),
                    color: Color(0xFFF4F1F1),
                    btnText: Colors.black,
                    iconAssetPath: "assets/plus.png",
                    constraints: constraints,
                  ),
                  SizedBox(width: 20,),
                  RectangularIBtn(

                    onPressed: () async {
                     String res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerScreen()));
                      setState(() {
                        if (res is String && res != '') {
                          _scanBarcodeResult = res;
                          if(!_barcodeList.contains({'barcode': _scanBarcodeResult})){
                            _barcodeList.insert(0,{'barcode': _scanBarcodeResult, 'quantity': '1'});
                            _saveBarcodeList();
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Barcode Already Scanned!'),
                            ),
                          );
                          }
                        } else if(res == "-1") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Try again to scan a barcode.'),
                            ),
                          );
                        }
                      });
                    },

                    // onPressed: () async {
                    //   await newBarcodeScan();
                    //  // barcodeScanStream();
                    // },
                    text: languageProvider.translate('Scan Samples'),
                    color: Colors.red,
                    btnText: Colors.white,
                    iconAssetPath: "assets/qr.png",
                    constraints: constraints,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
