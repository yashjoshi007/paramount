import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/textField.dart';
import '../login/login.dart';
import 'articleDetailScreen.dart';
import 'package:http/http.dart' as http;

class HomePageColleague extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePageColleague> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedLanguage;
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
    _clearUserDetails(); // Clear user details on app start
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
              builder: (context) => ArticleDetailsPage(articleDetails: article),
            ),
          );
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

  @override
  Widget build(BuildContext context) {
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
                  'Logout',
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
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              RadioListTile<String>(
                title: Text('Chinese (Simplied)', style: GoogleFonts.poppins()),
                value: 'Chinese (Simplied)',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              RadioListTile<String>(
                title: Text('Chinese (Traditional)', style: GoogleFonts.poppins()),
                value: 'Chinese (Traditional)',
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
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
                        'Enter Details',
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
                                labelText: 'Name',
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
                                labelText: 'Company Name',
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
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            String name = _nameController.text;
                            String companyName = _companyNameController.text;
                            String email = _emailController.text;
                            await saveUserDetails(name, companyName, email);
                            setState(() {});
                          },
                          child: Text('Add'),
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
                                  'Customer Details',
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
                                  'Name: ${userDetails['name']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,10,0,10),
                                child: Text(
                                  'Company Name: ${userDetails['companyName']}',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,10,0,10),
                                child: Text(
                                  'Email: ${userDetails['email']}',
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
                        'Sample List',
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
                        return Card(
                          elevation: 4.0,
                          child: GestureDetector(
                            onTap: () {
                              // Handle tap on the list tile
                              _fetchArticleDetails(_barcodeList[index]['barcode']);
                            },
                            child: Card(
                              elevation: 4.0,
                              child: ListTile(
                                leading: Icon(Icons.qr_code),
                                title: Text(
                                  'Barcode: ${_barcodeList[index]['barcode']}',
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
                text: 'Add Manually',
                color: Colors.grey,
                btnText: Colors.black,
                iconAssetPath: "assets/plus.png",
              ),
              SizedBox(width: 20),
              RectangularICBtn(
                onPressed: () async {
                  scanBarcodeNormal();
                },
                text: 'Scan Samples',
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
