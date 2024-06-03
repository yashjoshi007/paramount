import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllSittingPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllSittingPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

  @override
  State<AllSittingPage> createState() => _AllSittingPageState();
}

class _AllSittingPageState extends State<AllSittingPage> {

  Map<String, Map<String, dynamic>> _foundDetails = {};

  @override
  initState(){
    _foundDetails = widget.articleDetails;
    super.initState();
  }

  void _searchFunc(String articleNumber){
    Map<String, Map<String, dynamic>> results = {};
    if(articleNumber.isEmpty){
      results = widget.articleDetails;
    } else {
      results = widget.articleDetails.entries.where((entry) {
        return entry.key.contains(articleNumber);
      }).fold({}, (map, entry) {
        map[entry.key] = entry.value;
        return map;
      });
    }
    setState(() {
      _foundDetails = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitting Data Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => _searchFunc(value),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                  hintText: "Search Sitting",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const[
                  DataColumn(label: Text('Article No')),
                  DataColumn(label: Text('Similar')),
                  DataColumn(label: Text('Composition')),
                  DataColumn(label: Text('Texture')),
                  DataColumn(label: Text('Finish')),
                  DataColumn(label: Text('UsedWT')),
                  DataColumn(label: Text('Width')),
                  DataColumn(label: Text('ColorCode')),
                  DataColumn(label: Text('E_Color')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Unit')),
                  DataColumn(label: Text('L1')),
                  DataColumn(label: Text('Remark')),
                ],
                rows: _foundDetails.entries.map((entry) {
                  String key = entry.key;
                  Map<String, dynamic> value = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(key)),
                      DataCell(Text(value["Similar"]?.toString() ?? "")),
                      DataCell(Text(value["Compo"]?.toString() ?? "")),
                      DataCell(Text(value["Texture"]?.toString() ?? "")),
                      DataCell(Text(value["Finish"]?.toString() ?? "")),
                      DataCell(Text(value["UsedWT"]?.toString() ?? "")),
                      DataCell(Text(value["Width"]?.toString() ?? "")),
                      DataCell(Text(value["ColorCode"]?.toString() ?? "")),
                      DataCell(Text(value["E_Color"]?.toString() ?? "")),
                      DataCell(Text(value["Quantity"]?.toString() ?? "")),
                      DataCell(Text(value["Unit"]?.toString() ?? "")),
                      DataCell(Text(value["L1"]?.toString() ?? "")),
                      DataCell(Text(value["Remark"]?.toString() ?? "")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



          