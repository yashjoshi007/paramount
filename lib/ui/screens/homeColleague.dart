import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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
  List<Map<String, dynamic>> _barcodeList = [];
  String _scanBarcodeResult = "";

  Future<void> signOutGoogle() async {
    await _clearUserDetails();
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
   // _clearUserDetails(); // Clear user details on app start
    _loadBarcodeList();
  }

  _clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userDetails');
  }

  _loadBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? barcodeListString = prefs.getStringList('barcodeList');
    if (barcodeListString != null) {
      setState(() {
        _barcodeList = barcodeListString.map<Map<String, dynamic>>((item) => json.decode(item)).toList();
      });
    }
  }

  _saveBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList = _barcodeList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('barcodeList', encodedList);
  }

  void _addArticleManually(String articleNo, int quantity) {
    setState(() {
      _barcodeList.add({'barcode': articleNo, 'quantity': quantity});
      _saveBarcodeList();
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
      _barcodeList.add({'barcode': barcodeScanRes, 'quantity': 1});
      _saveBarcodeList();
    });
  }

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
      title: Text(
        "Add Article Manually",
        style: GoogleFonts.poppins(),
      ),
      content: Column(
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
      actions: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _addArticleManually(articleNo, int.parse(quantity)); // Add article manually
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Add',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _fetchArticleDetails(String barcode) async {

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from closing when tapping outside
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    // Replace this URL with your actual Google Sheets API endpoint
    String apiUrl = 'https://script.googleusercontent.com/macros/echo?user_content_key=TDlb7rLM_rqiKYr72gebRVN0s-zVy74koY7tSPXgNt9y7MfOFmAsNEyqmemyJ-W35pPtyav9mVDiUy6QNPb9KChUStuwIoOim5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnHJ5yWFXmy7bGcFeDpHjdWgQ9vetL1X7__qJJSutHRKFd77SxtRRlYq3GttY1ADGP43MM7kX-KfDHzPnPB8uoh1aDoUU23LwIQ&lib=MIc7FXjH6n7WaW-Iw0K14H0X2Nb-b482m';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var article = data['data'].firstWhere((element) => element['Article_No'] == barcode, orElse: () => null);
        if (article != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleDetailsPage(articleDetails: article,userRole: widget.userRole),
            ),
          ).then((_) {
            // Close the dialog when navigating back from ArticleDetailsPage
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article not found')));
        }
      } else {
        // If the server returns an error response, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load article details')));
      }
    } catch (error) {
      // Handle errors
      print('Error fetching article details: $error');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching article details')));
    }
  }

  // void sendEmail(String recipient, String subject, String body) async {
  //   // Check if the device can send emails
  //   if (await canLaunch('mailto:$recipient')) {
  //     // Launch the email client
  //     await launch('mailto:$recipient?subject=$subject&body=$body');
  //   } else {
  //     // If the device cannot send emails, show an error message
  //     throw 'Could not launch email';
  //   }
  // }

  void sendEmail(String recipient, String subject, String body) async {
    final emailJsApiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

    // Replace these values with your EmailJS service ID and template ID
    final serviceId = 'service_s0bpub7';
    final templateId = 'template_22ev90g';

    // Construct the request body
    final requestBody = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': 'bOirGg6PsenrVhRpr',
      'template_params': {
        'to_email': recipient,
        'subject': subject,
        'body': body,
      },
    };

    try {
      final response = await http.post(
        Uri.parse(emailJsApiUrl),
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Email sent successfully!');
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          title: Center(child: Image.asset('assets/logo.png')),
          backgroundColor: Colors.white,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: loadUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
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
                              await saveUserDetails(name, companyName, email);
                              setState(() {});
                            }, text: 'Add', iconAssetPath: "assets/mbox.png", color: Colors.grey, btnText: Colors.black87,
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  languageProvider.translate('customer_det'),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
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
                          icon: Icon(Icons.delete), // Add delete icon
                          onPressed: () async {
                            setState(() {
                              _nameController.text = ''; // Clear text fields
                              _companyNameController.text = '';
                              _emailController.text = '';
                            });
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
                        languageProvider.translate('samp'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  // Display sample list here
                  Expanded(
                    child: ListView.builder(
                      itemCount: _barcodeList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              // Handle tap on the list tile
                              _fetchArticleDetails(_barcodeList[index]['barcode']);
                            },
                            child: Card(
                              elevation: 4.0,
                              child: ListTile(
                                leading: Icon(Icons.qr_code),
                                title: Text(
                                  '${languageProvider.translate('barcode')}: ${_barcodeList[index]['barcode']}',
                                  style: GoogleFonts.poppins(),
                                ),
                                subtitle: DelayedEditableTextField(
                                  initialValue: _barcodeList[index]['quantity'].toString(),
                                  onChanged: (value) {
                                    // Update the quantity when the user inputs a value
                                    _barcodeList[index]['quantity'] = int.tryParse(value) ?? 0;
                                  },
                                  onEditingComplete: () {
                                    // Save the updated list after a delay when editing is complete
                                    Future.delayed(Duration(milliseconds: 500), () {
                                      setState(() {
                                        _saveBarcodeList(); // Save the updated list
                                      });
                                    });
                                  },
                                ),
                                trailing: IconButton(
                                  icon: Image.asset(
                                    'assets/delete.png',
                                    color: Colors.red,
                                  ),
                                  onPressed: () => removeBarcode(index),
                                ),
                              ),
                            ),
                          );
                      },
                    ),

                  ),
                ],
              );
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RectangularICBtn(
                onPressed: () {
                  showAddArticleDialog(context);
                  print('First button pressed');
                },
                text: languageProvider.translate('add'),
                color: Colors.grey,
                btnText: Colors.black,
                iconAssetPath: "assets/plus.png",
              ),
              SizedBox(width: 20),
              RectangularICBtn(
                onPressed: () async {
                 scanBarcodeNormal();
                 // sendEmail('yashjoshi785@gmail.com',"Hii","Body");
                },
                text: languageProvider.translate('scan'),
                color: Colors.red,
                btnText: Colors.white,
                iconAssetPath: "assets/qr.png",
              ),
            ],
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
