import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/components/myBtn.dart';
import 'package:paramount/ui/screens/allArticlleScreen.dart';
import 'package:paramount/ui/screens/allExhibitScreen.dart';
import 'package:paramount/ui/screens/allSiittingScreen.dart';
// import 'package:paramount/ui/screens/exhibitDetailScreen.dart';
// import 'package:paramount/ui/screens/sittingDetailScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../../components/confirmation_page.dart';
import '../../components/confirmpage2.dart';
// import '../../components/textField.dart';
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
  bool showBottom = false;
  late Map<String, Map<String, dynamic>> articleInfo = {};
  late List<Map<String, dynamic>> exhibitInfo = [];
  late List<Map<String, dynamic>> sittingInfo = [];
  final String _getAPIkey =
      "https://script.google.com/macros/s/AKfycbwfWPoGmwHpRn9Y2DPWR8jPDcJZjcJVOM-EKC7aqJ9dG3smOAVTNa0uYrHne9nuPtlq/exec";
  String Email = '';
  var date_time;

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
    _getAllArticle();
    _getAllExhibit();
    _getAllSitting();
  }

  _clearUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userDetails');
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
          print(articleInfo.length);
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

  void _getAllExhibit() async {
    String apiUrl = '$_getAPIkey?action=getExhibitAll';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var tempList = data['data'] as List;
        List<Map<String, dynamic>> exhibits =
            tempList.map((e) => e as Map<String, dynamic>).toList();
        setState(() {
          exhibitInfo = exhibits;
          // print("Exhibit " + exhibitInfo.length.toString());
        });
        if (exhibitInfo.isEmpty) {
          _showPopupAlert('No data found');
        }
      } else {
        _showPopupAlert('Failed to load exhibit data, Restart App');
      }
    } catch (error) {
      _showPopupAlert('Error fetching exhibit details');
    }
  }

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
      // print('Error fetching Sitting details: $error');
      _showPopupAlert('Error fetching Sitting details');
    }
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
        _barcodeList = barcodeListString
            .map<Map<String, String>>(
                (item) => Map<String, String>.from(json.decode(item)))
            .toList();
      });
      _barcodeList.forEach((barcode) {
        print('Barcode: ${barcode['barcode']}, Name: ${barcode['quantity']}');
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

  Future<void> saveUserDetails(
      String name, String companyName, String email) async {
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

  Future _checkUserDetails() async {
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
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // void _fetchArticleDetails(String barcode) async {
  //   bool snackbarShown = false; // Flag to track whether a Snackbar is shown

  //   showDialog(
  //     context: context,
  //     barrierDismissible:
  //         false, // Prevent dialog from closing when tapping outside
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius:
  //               BorderRadius.circular(5), // Adjust border radius as needed
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
  //             SizedBox(
  //                 height:
  //                     50), // Add some space between CircularProgressIndicator and the text
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
  //   //  String apiUrl = 'https://script.googleusercontent.com/macros/echo?user_content_key=TDlb7rLM_rqiKYr72gebRVN0s-zVy74koY7tSPXgNt9y7MfOFmAsNEyqmemyJ-W35pPtyav9mVDiUy6QNPb9KChUStuwIoOim5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnHJ5yWFXmy7bGcFeDpHjdWgQ9vetL1X7__qJJSutHRKFd77SxtRRlYq3GttY1ADGP43MM7kX-KfDHzPnPB8uoh1aDoUU23LwIQ&lib=MIc7FXjH6n7WaW-Iw0K14H0X2Nb-b482m';
  //   // Replace this URL with your actual Google Sheets API endpoint
  //   String apiUrl =
  //       'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getArticleColleague&articleNumber=$barcode';

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

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Article not found',
  //             style: TextStyle(fontFamily: 'GoogleFonts.poppins'),
  //           ),
  //         ),
  //       );
  //       snackbarShown = true;
  //       Navigator.pop(context);
  //     } else {
  //       // If the server returns an error response, show an error message
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text('Failed to load article details',
  //               style: GoogleFonts.poppins())));
  //       snackbarShown = true;
  //       Navigator.pop(context);
  //     }
  //   } catch (error) {
  //     print('Error fetching article details: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Error fetching article details',
  //             style: GoogleFonts.poppins())));
  //     snackbarShown = true;
  //     Navigator.pop(context);
  //   }
  // }

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

  _setDateTime() {
    date_time = DateTime.now();
  }

  Future<void> doPostRequestColleague(BuildContext context) async {
    print("Started post function");
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
      String pickerEmail = '';
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> appUser =
            userSnapshot.data() as Map<String, dynamic>;
        pickerEmail = appUser['email'];
      }
      _setDateTime();

      Map<String, dynamic> requestData = {
        'date': date_time.toString(),
        'Sample_picker': pickerEmail,
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

    print("Ended post function");
  }

  /*Future<void> doPostRequest(BuildContext context) async {
    // URL of your Google Apps Script web app
    String scriptUrl =
        'https://script.google.com/macros/s/AKfycbyd6aJmcHBHy10jRtZmHgWra5cMvJjiGhuzpL_asQQEgli1EB0AXt4eeuD26JtOypp6/exec';

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
            builder: (context) => ConfirmPage(
              description: 'Mail has been successfully sent to PJC.',
              btnText: "Send",
            ),
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
                  ElevatedButton(
                    onPressed: () {
                      if (exhibitInfo.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllExhibitPage(
                              articleDetails: exhibitInfo,
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
                    child: Text('Exhibit Record',
                        // Text(languageProvider.translate('all_exhibit'),
                        style: GoogleFonts.poppins(color: Colors.black)),
                  ),
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
              title: Text('Chinese (Simplied)', style: GoogleFonts.poppins()),
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
              title:
                  Text('Chinese (Traditional)', style: GoogleFonts.poppins()),
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
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: loadUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CupertinoActivityIndicator(
                  color: Colors.red,
                  radius: 20,
                  animating: true,
                ),
              );
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
                                labelText:
                                    languageProvider.translate('comp_name'),
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

                              if (name.isEmpty ||
                                  companyName.isEmpty ||
                                  email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please fill in all the details',
                                      style: GoogleFonts.poppins(),
                                    ), // Prompt error message
                                  ),
                                );
                              } else {
                                await saveUserDetails(name, companyName, email);
                                setState(() {
                                  showBottom = true;
                                });
                              }
                            },
                            text: 'Add',
                            iconAssetPath: "assets/plus.png",
                            color: Color(0xFFF4F1F1),
                            btnText: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                  if (userDetailsAvailable) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                languageProvider.translate('customer_det'),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/delete.png',
                                  color: Colors.red,
                                ), // Add delete icon
                                onPressed: () async {
                                  setState(() {
                                    _nameController.text =
                                        ''; // Clear text fields
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
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${languageProvider.translate('name')}: ${userDetails['name']}',
                                style: GoogleFonts.poppins(),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${languageProvider.translate('comp_name')}: ${userDetails['companyName']}',
                                style: GoogleFonts.poppins(),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${languageProvider.translate('email')}: ${userDetails['email']}',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                  if (userDetailsAvailable)
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
                              doPostRequestColleague(context);
                              bool refresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConfirmPage2(
                                    description:
                                        languageProvider.translate('send_desc'),
                                    btnText: 'Send',
                                    userRole: widget.userRole,
                                    Email: '${userDetails['email']}',
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
                            iconAssetPath: "assets/save.png",
                            color: Color(0xFFF4F1F1),
                            btnText: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  // Display sample list here
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
