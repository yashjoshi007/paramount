import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/myBtn.dart';

class SittingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const SittingDetailsPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Sitting Details',style:GoogleFonts.poppins()),
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
                  _buildDetailRow('Similar', '${articleDetails['Similar'] ?? 'N/A'}'),
                  _buildDetailRow('Compo', '${articleDetails['Compo'] ?? 'N/A'}'),
                  _buildDetailRow('UsedWT', '${articleDetails['UsedWT'] ?? 'N/A'}'),
                  _buildDetailRow('Width', '${articleDetails['Width'] ?? 'N/A'}'),
                  _buildDetailRow('ColorCode', '${articleDetails['ColorCode'] ?? 'N/A'}'),
                  _buildDetailRow('E_Color', '${articleDetails['E_Color'] ?? 'N/A'}'),
                  _buildDetailRow('Quantity', '${articleDetails['Quantity'] ?? 'N/A'}'),
                  _buildDetailRow('Unit', '${articleDetails['Unit'] ?? 'N/A'}'),
                  _buildDetailRow('L1', '${articleDetails['L1'] ?? 'N/A'}'),
                  _buildDetailRow('Remark', '${articleDetails['Remark'] ?? 'N/A'}'),
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
