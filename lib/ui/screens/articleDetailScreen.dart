import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/myBtn.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const ArticleDetailsPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

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
                    // Handle button 1 tap
                  },
                  text: 'Exhibit', color: Color(0xFFF4F1F1), btnText: Colors.black,

                ),
                Spacer(),// Add some space between the buttons
                RectangularButton(
                  onPressed: () {
                    // Handle button 2 tap
                  }, text: 'Sitting', color: Color(0xFFF4F1F1), btnText: Colors.black,
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
                  _buildDetailRow('Article No', '${articleDetails['Article_No']}'),
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
