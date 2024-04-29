// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:paramount/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/textField.dart';
import '../../localization/language_provider.dart';
import '../login/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'articleDetailScreen.dart';

class HomePageClient extends StatefulWidget {
  final String userRole;
  const HomePageClient({Key? key, required this.userRole}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageClient> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedLanguage = 'en';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> _barcodeList = [];
  String _scanBarcodeResult = "";


  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
  }

  Future<void> signOutGoogle() async {
    await _clearBarcodeList();
    await _auth.signOut();
  }

  _clearBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('barcodeList');
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



  Future<void> scanBarcodeWithDelay() async {
    // Delay for 2 seconds before starting the barcode scanning
    await Future.delayed(Duration(seconds: 1));
    // Call the actual barcode scanning function after the delay
    scanBarcodeNormal();
  }


  _loadBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? barcodeListString = prefs.getStringList('barcodeList');
    if (barcodeListString != null) {
      setState(() {
        _barcodeList = barcodeListString.map<Map<String, String>>((item) => Map<String, String>.from(json.decode(item))).toList();
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
      _barcodeList.add({'barcode': articleNo, 'quantity': quantity.toString()});
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

    if (barcodeScanRes.length == 8 || barcodeScanRes.length == 9) {
      if (!mounted) return;
      setState(() {
        _scanBarcodeResult = barcodeScanRes;
        _barcodeList.add({'barcode': barcodeScanRes, 'quantity': "1"});
        _saveBarcodeList();
      });
    } else if(barcodeScanRes == "-1") {
      // Show snackbar if barcode length is not 8 or 9
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Try again to scan a barcode.'),
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan Barcode Properly.'),
        ),
      );
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
            if (!snackbarShown) {
              Navigator.pop(context);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article not found', style: GoogleFonts.poppins(),)));
          snackbarShown = true;
          Navigator.pop(context);
        }
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


  void removeBarcode(int index) {
    setState(() {
      _barcodeList.removeAt(index);
      _saveBarcodeList();
    });
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
                Text(languageProvider.translate('logout'), style: GoogleFonts.poppins(color: Colors.red),),
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
                title: Text('Chinese (Simplied)', style: GoogleFonts.poppins(),),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                  child: Text(
                    languageProvider.translate('samp'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Spacer(), // This will push the button to the extreme right
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: RectangularICBtn(
                    onPressed: () {
                      //showAddArticleDialog(context);
                    },
                    text: languageProvider.translate('email_list'),
                    color: Color(0xFFF4F1F1),
                    btnText: Colors.black,
                    iconAssetPath: "assets/mbox.png",
                  ),
                ),
              ],
            ),

            SizedBox(height: 10), // Add some space between the text and the list
            Expanded(
              child: _barcodeList.length != 0
                  ? Expanded(
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
                                  width: 30, // Set a fixed width for the input field
                                  child: DelayedEditableTextField(
                                    initialValue: _barcodeList[index]['quantity'].toString(),
                                    onChanged: (value) {
                                      // Update the quantity when the user inputs a value
                                      _barcodeList[index]['quantity'] = (int.tryParse(value) ?? 0) as String;
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
                                ),
                              ),
                              // Display delete icon
                              Expanded(
                                flex: 0, // Prevent delete icon from expanding
                                child: IconButton(
                                  icon: Image.asset(
                                    'assets/delete.png',
                                    color: Colors.red,
                                  ),
                                  onPressed: () => removeBarcode(index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )

                  : Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/qr2.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 25),
                      Text(
                        languageProvider.translate('empty_list'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: BottomAppBar(
          color:Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RectangularICBtn(
                onPressed: () {
                  showAddArticleDialog(context);
                },
                text: languageProvider.translate('add'),
                color: Color(0xFFF4F1F1),
                btnText: Colors.black,
                iconAssetPath: "assets/plus.png",
              ),
              SizedBox(width: 20,),
              RectangularICBtn(
                onPressed: () async {
                  scanBarcodeWithDelay();
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
}

