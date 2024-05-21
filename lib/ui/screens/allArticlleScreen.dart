import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/myBtn.dart';

class AllArticlePage extends StatelessWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllArticlePage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Data Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Article No')),
              DataColumn(label: Text('Composition')),
              DataColumn(label: Text('Texture')),
              DataColumn(label: Text('Finish')),
              DataColumn(label: Text('Density')),
              DataColumn(label: Text('Yarn_Count')),
              DataColumn(label: Text('Weight')),
              DataColumn(label: Text('Price.USD (\$)')),
              DataColumn(label: Text('Price.Yen (¥)')),
            ],
            rows: articleDetails.entries.map((entry) {
              String key = entry.key;
              Map<String, dynamic> value = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text(key)),
                  DataCell(Text(value["Compo"]?.toString() ?? "NA")),
                  DataCell(Text(value["Texture"]?.toString() ?? "NA")),
                  DataCell(Text(value["Finish"]?.toString() ?? "NA")),
                  DataCell(Text(value["Density"]?.toString() ?? "NA")),
                  DataCell(Text(value["Yarn_Count"]?.toString() ?? "NA")),
                  DataCell(Text(value["Weight"]?.toString() ?? "NA")),
                  DataCell(Text(value["Price_D"]?.toString() ?? "NA")),
                  DataCell(Text(value["Price_Y"]?.toString() ?? "NA")),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
