import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';

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
    final languageProvider = Provider.of<LanguageProvider>(context);
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
                columns: [
                 DataColumn(label: Text(languageProvider.translate('article_no'))),
                 DataColumn(label: Text(languageProvider.translate('similar'))),
                 DataColumn(label: Text(languageProvider.translate('composition'))),
                 DataColumn(label: Text(languageProvider.translate('texture'))),
                 DataColumn(label: Text(languageProvider.translate('finish'))),
                 DataColumn(label: Text(languageProvider.translate('usedwt'))),
                 DataColumn(label: Text(languageProvider.translate('width'))),
                 DataColumn(label: Text(languageProvider.translate('color_code'))),
                 DataColumn(label: Text(languageProvider.translate('e_color'))),
                 DataColumn(label: Text(languageProvider.translate('quantity'))),
                 DataColumn(label: Text(languageProvider.translate('unit'))),
                 DataColumn(label: Text(languageProvider.translate('l1'))),
                 DataColumn(label: Text(languageProvider.translate('remark'))),
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



          