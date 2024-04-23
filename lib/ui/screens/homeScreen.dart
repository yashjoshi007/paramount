// ignore_for_file: unused_field

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:paramount/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localization/language_provider.dart';
import '../login/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePageClient extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageClient> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedLanguage = 'en';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> _barcodeList = [];
  String _scanBarcodeResult = "";

  Future<void> signOutGoogle() async {
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
  }

  _loadBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _barcodeList = (prefs.getStringList('barcodeList') ?? []).map((barcode) => {'barcode': barcode, 'description': ''}).toList();
    });
  }

  _saveBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('barcodeList', _barcodeList.map((item) => item['barcode']!).toList());
  }


  Future<void> scanBarcodeWithDelay() async {
    // Delay for 2 seconds before starting the barcode scanning
    await Future.delayed(Duration(seconds: 1));
    // Call the actual barcode scanning function after the delay
    scanBarcodeNormal();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);

      if (barcodeScanRes.length == 9) {
        setState(() {
          // Add the barcode directly to the list
          _barcodeList.add({'barcode': barcodeScanRes, 'description': ''});
          _saveBarcodeList();
        });
      } else {
        // Show toast message for improper scanning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan the barcode properly.'),
          ),
        );
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _scanBarcodeResult = barcodeScanRes;
    });
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
                  icon: Image.asset('assets/logout.png', color: Colors.red,),
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
        body: _barcodeList.length != 0
            ? ListView.builder(
          itemCount: _barcodeList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4.0,
              child: ListTile(
                leading: Icon(Icons.qr_code),
                title: Text(
                  'Barcode: ${_barcodeList[index]['barcode']}',
                  style: GoogleFonts.poppins(),
                ),
                subtitle: Text(
                  _barcodeList[index]['description'] ?? '',
                  style: GoogleFonts.poppins(),
                ),
                trailing: IconButton(
                  icon: Image.asset(
                    'assets/delete.png',
                    color: Colors.red,
                  ),
                  onPressed: () => removeBarcode(index),
                ),
              ),
            );
          },
        )
            : Center(
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
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RectangularICBtn(
                onPressed: () {
                  // Handle the first button press
                  print('First button pressed');
                },
                text: languageProvider.translate('email_list'),
                color: Colors.grey,
                btnText: Colors.black,
                iconAssetPath: "assets/mbox.png",
              ),
              SizedBox(width: 20,),
              RectangularICBtn(
                onPressed: () async {
                  scanBarcodeWithDelay();
                },
                text: languageProvider.translate('add_p'),
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

