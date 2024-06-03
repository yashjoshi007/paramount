import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../components/myBtn.dart';

class ExhibitDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const ExhibitDetailsPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Exhibit Details',style:GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ // Add some space between the buttons and the DataTable
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Detail', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Value', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
                ],
                rows: [
                  _buildDetailRow('Exhibit Samples', '${articleDetails['Exhibit_Samples'] ?? 'N/A'}'),
                  _buildDetailRow('Exhibit', '${articleDetails['Exhibit'] ?? 'N/A'}'),
                  _buildDetailRow('Exhibit Position', '${articleDetails['Exhibit_Position'] ?? 'N/A'}'),
                  _buildDetailRow('Title', '${articleDetails['Title'] ?? 'N/A'}'),
                  _buildDetailRow('SubTitle', '${articleDetails['SubTitle'] ?? 'N/A'}'),
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
