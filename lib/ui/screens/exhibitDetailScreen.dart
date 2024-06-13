import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../../components/myBtn.dart';

class ExhibitDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> articleDetails;
  final String userRole;
  final String barcode; // Assuming user role is passed to this widget

  const ExhibitDetailsPage({Key? key, required this.articleDetails, required this.userRole, required this.barcode}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Exhibit Details',style:GoogleFonts.poppins()),
      ),
      body: ListView.builder(
        itemCount: articleDetails.length,
        itemBuilder: (context, index) {
          // String key = _foundDetails.keys.elementAt(index);
          Map<String, dynamic> value = articleDetails[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Article No: ${value['article_number']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Exhibit Samples: ${value["Exhibit_Samples"]?.toString() ?? "NA"}'),
                  Text('Exhibit: ${value["Exhibit"]?.toString() ?? "NA"}'),
                  Text(
                      'Exhibit Position: ${value["Exhibit_Position"]?.toString() ?? "NA"}'),
                  Text('Title: ${value["Title"]?.toString() ?? "NA"}'),
                  Text('SubTitle: ${value["SubTitle"]?.toString() ?? "NA"}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // DataRow _buildDetailRow(String title, String value) {
  //   return DataRow(cells: [
  //     DataCell(Text(title,style:GoogleFonts.poppins())),
  //     DataCell(Text(value,style:GoogleFonts.poppins())),
  //   ]);
  // }
}
