import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const ArticleDetailsPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Article Details',style:GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Detail',style:GoogleFonts.poppins(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Value',style:GoogleFonts.poppins(fontWeight: FontWeight.w700))),
            ],
            rows: [
              _buildDetailRow('Article No', '${articleDetails['Article_No']}'),
              _buildDetailRow('Composition', '${articleDetails['Compo']}'),
              _buildDetailRow('Texture', '${articleDetails['Texture']}'),
             _buildDetailRow('Finish', '${articleDetails['Finish']}'),
              if (userRole == 'colleague')_buildDetailRow('Density', '${articleDetails['Density']}'),
              if (userRole == 'colleague') _buildDetailRow('Yarn Count', '${articleDetails['Yarn_Count']}'),
              _buildDetailRow('Weight', '${articleDetails['Weight']}'),
              _buildDetailRow('Price_D', '${articleDetails['Price_D']}'),
              _buildDetailRow('Price_Y', '${articleDetails['Price_Y']}'),
            ],
          ),
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
