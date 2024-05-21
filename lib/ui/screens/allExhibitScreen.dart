import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/myBtn.dart';

class AllExhibitPage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllExhibitPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibit Data Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const[
              DataColumn(label: Text('Article No')),
              DataColumn(label: Text('Exhibit_Samples')),
              DataColumn(label: Text('Exhibit')),
              DataColumn(label: Text('Exhibit_Position')),
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('SubTitle')),
            ],
            rows: articleDetails.entries.map((entry) {
              String key = entry.key;
              Map<String, dynamic> value = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(key)),
                  DataCell(Text(value["Exhibit_Samples"] ?? "")),
                  DataCell(Text(value["Exhibit"] ?? "")),
                  DataCell(Text(value["Exhibit_Position"] ?? "")),
                  DataCell(Text(value["Title"] ?? "")),
                  DataCell(Text(value["SubTitle"] ?? "")),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
