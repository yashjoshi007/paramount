import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
// import 'package:paramount/models/user_model.dart';
import 'package:paramount/ui/screens/allArticlleScreen.dart';
// import 'package:paramount/ui/screens/allExhibitScreen.dart';
import 'package:paramount/ui/screens/allSiittingScreen.dart';
// import 'package:paramount/ui/screens/exhibitDetailScreen.dart';
// import 'package:paramount/ui/screens/sittingDetailScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/confirmation_page.dart';
import '../../components/confirmpage2.dart';
// import '../../components/textField.dart';
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
  final TextEditingController unitController = new TextEditingController();
  String? _selectedLanguage = 'en';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> _barcodeList = [];
  String _scanBarcodeResult = "";
  String Email = '';
  String? res;
  late Map<String, Map<String, dynamic>> articleInfo = {};
  late List<Map<String, dynamic>> exhibitInfo = [];
  late List<Map<String, dynamic>> sittingInfo = [];
  final String _getAPIkey =
      "https://script.google.com/macros/s/AKfycbwfWPoGmwHpRn9Y2DPWR8jPDcJZjcJVOM-EKC7aqJ9dG3smOAVTNa0uYrHne9nuPtlq/exec";
  // late Map<String, Map<String, dynamic>> sittingInfo = {};
  var date_time;

  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
    _getAllArticle();
    // _getAllExhibit();
    _getAllSitting();
  }

  Future<void> signOutGoogle() async {
    await _clearBarcodeList();
    await _auth.signOut();
  }

  _clearBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('barcodeList');
  }

  Widget _buildUnitDropdown(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' Unit', // Add a label above the dropdown
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12),
        ),
        SizedBox(
            height: 8), // Add some space between the label and the dropdown
        DropdownButton<String>(
          value: _barcodeList[index]
              ['unit'], // Set initial value to the existing unit, if any
          onChanged: (String? newValue) {
            setState(() {
              _barcodeList[index]['unit'] =
                  newValue!; // Update unit for this barcode
              _saveBarcodeList();
            });
          },
          items: <String>['M', 'Y', 'Hanger', 'Header', '-NA-']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
        ),
      ],
    );
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
        borderRadius:
            BorderRadius.circular(6), // Adjust border radius as needed
      ),
      title: Text(
        "Add Article Manually",
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        width:
            MediaQuery.of(context).size.width * 0.7, // Adjust width as needed
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
      actionsPadding:
          EdgeInsets.symmetric(horizontal: 20), // Add padding to actions
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      5), // Adjust border radius as needed
                  color: Color(0xFFF4F1F1), // Set the background color
                ),
                child: TextButton(
                  onPressed: () {
                    _addArticleManually(
                        articleNo, int.parse(quantity)); // Add article manually
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 5), // Adjust button padding
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
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // Adjust button padding
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

  void _showPopupAlert(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            title: Text('Alert', style: GoogleFonts.poppins()),
            content: Text(message, style: GoogleFonts.poppins()),
          );
        });
  }

  void _getAllArticle() async {
    String apiUrl = '$_getAPIkey?action=getArticleAll';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var articles = data['data'] as Map<String, dynamic>;
        setState(() {
          articleInfo = articles.map(
              (key, value) => MapEntry(key, value as Map<String, dynamic>));
          // print("Art " + articleInfo.length.toString());
        });
        if (articleInfo.isEmpty) {
          _showPopupAlert('No data found');
        }
      } else {
        _showPopupAlert('Failed to load article details, Restart app');
      }
    } catch (error) {
      // print('Error fetching article details: $error');
      _showPopupAlert('Error fetching article details');
    }
  }

  void _fetchArticle(String barcode) {
    if (articleInfo.isNotEmpty) {
      var articleDetails = articleInfo[barcode];
      // var exhibitDetails = exhibitInfo[barcode]?? <String, dynamic>{};
      List<Map<String, dynamic>> exhibitDetails = [];
      if (exhibitInfo.any((element) => element['article_number'] == barcode)) {
        exhibitDetails = exhibitInfo
            .where((element) => element['article_number'] == barcode)
            .toList();
      }
      List<Map<String, dynamic>> sittingDetails = [];
      if (sittingInfo.any((element) => element['article_number'] == barcode)) {
        sittingDetails = sittingInfo
            .where((element) => element['article_number'] == barcode)
            .toList();
      }
      // var sittingDetails = sittingInfo.where((element) => element['article_number'] == barcode) ?? <String, dynamic>{};
      if (articleDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailsPage(
              articleDetails: articleDetails,
              exhibitDetails: exhibitDetails,
              sittingDetails: sittingDetails,
              userRole: widget.userRole,
              barcode: barcode,
            ),
          ),
        );
        return;
      } else {
        _showPopupAlert('No data found');
      }
    } else {
      _showPopupAlert('Failed! Try again...');
    }
  }

///////--------Not Needed in Customer Interface--------/////////
  // void _getAllExhibit() async {
  //   String apiUrl = 'https://script.google.com/macros/s/AKfycbwlfRxY91iDaP_bXC1DozDB_FlJ3HF1j7qLO6zwuePAbTAcldwxO59m75uY1VvaWZwG/exec?action=getExhibitAll';

  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     print(response.statusCode);

  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       var tempList= data['data'] as List;
  //       List<Map<String, dynamic>> exhibits = tempList.map((e) => e as Map<String, dynamic>).toList();
  //       setState(() {
  //         exhibitInfo = exhibits;
  //         // print("Exhibit " + exhibitInfo.length.toString());
  //       });
  //       if (exhibitInfo.isEmpty) {
  //         _showPopupAlert('No data found');
  //       }
  //     } else {
  //       _showPopupAlert('Failed to load exhibit data, Restart App');
  //     }
  //   } catch (error) {
  //     _showPopupAlert('Error fetching exhibit details');
  //   }
  // }

  void _getAllSitting() async {
    String apiUrl = '$_getAPIkey?action=getSittingAll';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var tempList = data['data'] as List;
        List<Map<String, dynamic>> sittings =
            tempList.map((e) => e as Map<String, dynamic>).toList();
        setState(() {
          sittingInfo = sittings;
          // print("Sitting " + sittingInfo.length.toString());
        });
        if (sittingInfo.isEmpty) {
          _showPopupAlert('No data found');
        }
      } else {
        _showPopupAlert('Failed to load sitting data, Restart App');
      }
    } catch (error) {
      print('Error fetching Sitting details: $error');
      _showPopupAlert('Error fetching Sitting details');
    }
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
        print(
            'Barcode: ${barcode['barcode']}, Quantity: ${barcode['quantity']}, Unit: ${barcode['unit']}');
        // Add other properties if available
      });
    }
  }

  _saveBarcodeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedList =
        _barcodeList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('barcodeList', encodedList);
  }

  _setDateTime() {
    date_time = DateTime.now();
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
          'Sample_picker': email,
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

  /*Future<void> doPostRequest(BuildContext context) async {
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
        // ignore: unused_local_variable
        String role = userData['role'];
        Email = email;

        // Load barcode list
        _loadBarcodeList(); // Assuming this function updates _barcodeList

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
          // Navigate to another page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmPage(
                description:
                    'Mail has been successfully sent to PMT-TXT and your account.',
                btnText: 'Send',
              ),
            ),
          );

          await _clearBarcodeList();
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }*/

  void _addArticleManually(String articleNo, int quantity) {
    setState(() {
      _barcodeList.insert(0, {
        'barcode': articleNo,
        'quantity': quantity.toString(),
        'unit': 'Header'
      });
      _saveBarcodeList();
    });
  }

  // newBarcodeScan() async {
  //   var res = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Done', true, ScanMode.BARCODE);
  //   setState(() {
  //     if (res is String && res != '') {
  //       _scanBarcodeResult = res;
  //       if (!_barcodeList.any((item) => item['barcode'] == _scanBarcodeResult)) {
  //         _barcodeList.add({
  //           'barcode': _scanBarcodeResult,
  //           'quantity': '1',
  //           'unit': 'Header', // Set default unit to 'A'
  //         });
  //         _saveBarcodeList();
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Barcode Already Scanned!'),
  //           ),
  //         );
  //       }
  //     } else if (res == "-1") {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Try again to scan a barcode.'),
  //         ),
  //       );
  //     }
  //   });
  // }

  // Future<void> scanBarcodeNormal() async {
  //   String barcodeScanRes;
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.BARCODE);
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

  // void _fetchArticleDetails(String barcode) async {
  //   bool snackbarShown = false; // Flag to track whether a Snackbar is shown

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevent dialog from closing when tapping outside
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(5), // Adjust border radius as needed
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Center(
  //               child: CupertinoActivityIndicator(
  //                 color: Colors.red,
  //                 radius: 20,
  //                 animating: true,
  //               ),
  //             ),
  //             SizedBox(height: 50), // Add some space between CircularProgressIndicator and the text
  //             Text(
  //               'Loading Article Details...', // Add your desired text here
  //               style: GoogleFonts.poppins(
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //  //  String apiUrl = 'https://script.googleusercontent.com/macros/echo?user_content_key=TDlb7rLM_rqiKYr72gebRVN0s-zVy74koY7tSPXgNt9y7MfOFmAsNEyqmemyJ-W35pPtyav9mVDiUy6QNPb9KChUStuwIoOim5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnHJ5yWFXmy7bGcFeDpHjdWgQ9vetL1X7__qJJSutHRKFd77SxtRRlYq3GttY1ADGP43MM7kX-KfDHzPnPB8uoh1aDoUU23LwIQ&lib=MIc7FXjH6n7WaW-Iw0K14H0X2Nb-b482m';
  //   // Replace this URL with your actual Google Sheets API endpoint
  //   String apiUrl = 'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getArticleColleague&articleNumber=$barcode';

  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       var article = data['data'];
  //       if (article != null && article.isNotEmpty) {
  //         var articleDetails = article[barcode];
  //         if (articleDetails != null) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ArticleDetailsPage(
  //                 articleDetails: articleDetails,
  //                 userRole: widget.userRole,
  //                 barcode: barcode,
  //               ),
  //             ),
  //           ).then((_) {
  //             if (!snackbarShown) {
  //               Navigator.pop(context);
  //             }
  //           });
  //           return;
  //         }
  //       }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Article not found',
  //           style: TextStyle(fontFamily: 'GoogleFonts.poppins'),
  //         ),
  //       ),
  //     );
  //     snackbarShown = true;
  //     Navigator.pop(context);
  //   } else {
  //       // If the server returns an error response, show an error message
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load article details',style: GoogleFonts.poppins())));
  //       snackbarShown = true;
  //       Navigator.pop(context);
  //     }
  //   } catch (error) {
  //     print('Error fetching article details: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching article details',style: GoogleFonts.poppins())));
  //     snackbarShown = true;
  //     Navigator.pop(context);
  //   }
  // }

  void removeBarcode(int index) {
    setState(() {
      _barcodeList.removeAt(index);
      _saveBarcodeList();
    });
  }

  /*void sendEmails(
      String recipient, String subject, List<Map<String, String>> barcodeList,
      {required List<String> cc}) async {
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
  }*/

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (articleInfo.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllArticlePage(
                              articleDetails: articleInfo,
                              userRole: widget.userRole,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      backgroundColor: Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                    ),
                    child: Text('Article Record',
                        // Text(languageProvider.translate('all_articles'),
                        style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                  // Second TextButton
                  // ElevatedButton(
                  //   onPressed: () {
                  //       if(exhibitInfo.isNotEmpty){
                  //         Navigator.push(
                  //         context,
                  //           MaterialPageRoute(
                  //             builder: (context) =>
                  //                 AllExhibitPage(
                  //                   articleDetails: exhibitInfo, userRole: widget.userRole,
                  //                 ),
                  //           ),
                  //         );
                  //       }
                  //     },
                  //   style: ElevatedButton.styleFrom(
                  //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  //     backgroundColor: Color(0xFFF4F1F1),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(5),
                  //     ),
                  //     elevation: 0,
                  //   ),
                  //   child: Text(languageProvider.translate('all_exhibit'), style: GoogleFonts.poppins(color: Colors.black)),
                  // ),
                  // Third TextButton
                  ElevatedButton(
                    onPressed: () {
                      if (sittingInfo.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllSittingPage(
                              articleDetails: sittingInfo,
                              userRole: widget.userRole,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      backgroundColor: Color(0xFFF4F1F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                      // shadowColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text('Sitting Samples',
                        // Text(languageProvider.translate('all_sitting'),
                        style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 230, 227, 227),
                ),
              ),
            ],
          ),
        ),
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
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLanguage(_selectedLanguage!);
              Navigator.pop(context); // Close the drawer
            },
          ),
          RadioListTile<String>(
            title: Text('Chinese (Simplified)', style: GoogleFonts.poppins()),
            value: 'ch_si',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value;
              });
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLanguage(_selectedLanguage!);
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
              Provider.of<LanguageProvider>(context, listen: false)
                  .setLanguage(_selectedLanguage!);
              Navigator.pop(context); // Close the drawer
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete Account', style: GoogleFonts.poppins()),
            onTap: () async {
              // Confirm delete action
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Delete', style: GoogleFonts.poppins(),),
                  content: Text('Are you sure you want to delete your account? *This action cannot be undone.*', style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ),
              );

              if (confirmDelete) {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await user.delete();
                    // Navigate to home page
                     Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  }
                } catch (e) {
                  // Handle error (e.g., re-authentication required)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting account: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey[200],
              height: 60.0, // Adjust height as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // First TextButton
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                      // shadowColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text('All Exhibit', style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                  // Second TextButton
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                      // shadowColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text('All Exhibit', style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                  // Third TextButton
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 0,
                      // shadowColor: Colors.black.withOpacity(0.7),
                    ),
                    child: Text('All Exhibit', style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10, 0, 0),
                  child: Text(
                    languageProvider.translate('Selected Samples'),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Spacer(), // This will push the button to the extreme right
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: RectangularICBtn(
                    onPressed: () async {
                      doPostRequestCustomer(context);
                      bool refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmPage2(
                            description:
                                languageProvider.translate('send_desc'),
                            btnText: languageProvider.translate('sent'),
                            userRole: widget.userRole,
                            Email: Email,
                          ),
                        ),
                      );
                      if (refresh == true) {
                        setState(() {
                          _barcodeList = [];
                        });
                      }
                    },
                    text: languageProvider.translate('Save List @PMT'),
                    color: Color(0xFFF4F1F1),
                    btnText: Colors.black,
                    iconAssetPath: "assets/save.png",
                  ),
                ),
              ],
            ),

            SizedBox(
                height: 10), // Add some space between the text and the list
            Expanded(
              child: _barcodeList.length != 0
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0), // Add padding from left and right
                      child: ListView.builder(
                        itemCount: _barcodeList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _fetchArticle(_barcodeList[index]['barcode']!);
                            },
                            child: Card(
                              elevation: 0.0,
                              color: Color(0xFFF4F1F1),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Display barcode and leading icon
                                    Row(
                                      children: [
                                        Icon(Icons.qr_code),
                                        SizedBox(width: 4),
                                        Text(
                                          '${languageProvider.translate('barcode')}:\n${_barcodeList[index]['barcode']}',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    // Display quantity input field
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 76,
                                          child: TextField(
                                            decoration: InputDecoration(
                                              labelText: 'Qty',
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: TextEditingController(
                                              text: _barcodeList[index]
                                                  ['quantity'],
                                            ),
                                            onChanged: (value) {
                                              _barcodeList[index]['quantity'] =
                                                  value;
                                            },
                                            onEditingComplete: () {
                                              FocusScope.of(context).unfocus();
                                              Future.delayed(
                                                  Duration(milliseconds: 500),
                                                  () {
                                                setState(() {
                                                  _saveBarcodeList();
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                        // Display unit dropdown button
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: _buildUnitDropdown(index),
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
                              languageProvider.translate(
                                  'No items in the list, scan or add from below buttons'),
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
      ),
      bottomNavigationBar: BottomAppBar(
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
                  constraints:
                      constraints, // Pass the constraints for responsiveness
                ),
                SizedBox(
                  width: 20,
                ),
                RectangularIBtn(
                  onPressed: () async {
                    var code = await BarcodeScanner.scan();
                    String res = code.rawContent;
                    setState(() {
                      if (res != '') {
                        _scanBarcodeResult = res;
                        if (!_barcodeList
                            .contains({'barcode': _scanBarcodeResult})) {
                          _barcodeList.insert(0, {
                            'barcode': _scanBarcodeResult,
                            'quantity': '1',
                            'unit': 'Header',
                          });
                          _saveBarcodeList();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Barcode Already Scanned!'),
                            ),
                          );
                        }
                      } else if (res == "-1") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Try again to scan a barcode.'),
                          ),
                        );
                      }
                    });
                  },
                  text: languageProvider.translate('Scan Samples'),
                  color: Colors.red,
                  btnText: Colors.white,
                  iconAssetPath: "assets/qr.png",
                  constraints:
                      constraints, // Pass the constraints for responsiveness
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
