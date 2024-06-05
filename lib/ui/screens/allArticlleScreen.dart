import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';

class AllArticlePage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllArticlePage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

  @override
  State<AllArticlePage> createState() => _AllArticlePageState();
}

class _AllArticlePageState extends State<AllArticlePage> {

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
        title: const Text('Article Data Table'),
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
                  hintText: "Search Article",
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
                columns:  [
                 DataColumn(label: Text(languageProvider.translate('article_no'))),
                 DataColumn(label: Text(languageProvider.translate('composition'))),
                 DataColumn(label: Text(languageProvider.translate('texture'))),
                 DataColumn(label: Text(languageProvider.translate('finish'))),
                 DataColumn(label: Text(languageProvider.translate('density'))),
                 DataColumn(label: Text(languageProvider.translate('yarn_count'))),
                 DataColumn(label: Text(languageProvider.translate('weight'))),
                 DataColumn(label: Text(languageProvider.translate('price_usd'))),
                 DataColumn(label: Text(languageProvider.translate('price_yen'))),
                ],
                rows: _foundDetails.entries.map((entry) {
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
          ],
        ),
      ),
    );
  }
}
