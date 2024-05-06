import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paramount/ui/screens/sittingDetailScreen.dart';
import '../../components/myBtn.dart';
import 'package:http/http.dart' as http;

import 'exhibitDetailScreen.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;
  final String userRole;
  final String barcode;// Assuming user role is passed to this widget
  String btnPressed = '';

  ArticleDetailsPage({Key? key, required this.articleDetails, required this.userRole,required this.barcode}) : super(key: key);



  void _fetchArticleDetails(BuildContext context,String barcode) async {
    bool snackbarShown = false; // Flag to track whether a Snackbar is shown
    String apiUrl = '';
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
               btnPressed=='Exhibit'? 'Loading Exhibit Details...':'Loading Sitting Details...', // Add your desired text here
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
    if(btnPressed=='Exhibit') {
      apiUrl = 'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getExhibitSamples&articleNumber=$barcode';
    }else if(btnPressed=='Sitting'){
      if(userRole == "customer" || userRole == "Customer") {
        apiUrl = 'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getSittingCustomer&articleNumber=$barcode';
      }else if(userRole=="colleague" || userRole == "Colleague")
        {
          apiUrl = 'https://script.google.com/macros/s/AKfycbyTndTH9oJH--MrerYAmUFHDrxpOMmri_8ziWWcEyMUwcoqMQ3beUyhVCAByBlODzNe/exec?action=getSittingColleague&articleNumber=$barcode';
        }
    }
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var article = data['data'];
        if (article != null && article.isNotEmpty) {
          var articleDetails = article[barcode];
          if (articleDetails != null) {
            if(btnPressed=='Exhibit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExhibitDetailsPage(
                        articleDetails: articleDetails, userRole: '',
                      ),
                ),
              ).then((_) {
                if (!snackbarShown) {
                  Navigator.pop(context);
                }
              });
            }else if(btnPressed=='Sitting')
              {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SittingDetailsPage(
                          articleDetails: articleDetails, userRole: '',
                        ),
                  ),
                ).then((_) {
                  if (!snackbarShown) {
                    Navigator.pop(context);
                  }
                });
              }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Article Details',style:GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                RectangularButton(
                  onPressed: () {
                    btnPressed = 'Exhibit';
                    _fetchArticleDetails(context,barcode);
                  },
                  text: 'Exhibit Samples', color: Color(0xFFF4F1F1), btnText: Colors.black,

                ),
                Spacer(),// Add some space between the buttons
                RectangularButton(
                  onPressed: () {
                    btnPressed = 'Sitting';
                    _fetchArticleDetails(context,barcode);
                  }, text: 'Sitting Samples', color: Color(0xFFF4F1F1), btnText: Colors.black,
                ),
              ],
            ),

            SizedBox(height: 16), // Add some space between the buttons and the DataTable
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Value', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                ],
                rows: [
                  _buildDetailRow('Article No', '${barcode}'),
                  _buildDetailRow('Composition', '${articleDetails['Compo']}'),
                  _buildDetailRow('Texture', '${articleDetails['Texture']}'),
                  _buildDetailRow('Finish', '${articleDetails['Finish']}'),
                  if (userRole == 'colleague') _buildDetailRow('Density', '${articleDetails['Density']}'),
                  if (userRole == 'colleague') _buildDetailRow('Yarn Count', '${articleDetails['Yarn_Count']}'),
                  _buildDetailRow('Weight', '${articleDetails['Weight']}'),
                  _buildDetailRow('Price_D', '${articleDetails['Price_D']}'),
                  _buildDetailRow('Price_Y', '${articleDetails['Price_Y']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDetailRow(String title, String value) {
    return DataRow(cells: [
      DataCell(Text(title,style:GoogleFonts.poppins())),
      DataCell(Text(value,style:GoogleFonts.poppins())),
    ]);
  }
}
