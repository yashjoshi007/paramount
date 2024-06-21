import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';

class AllSittingPage extends StatefulWidget {
  final List<Map<String, dynamic>> articleDetails;
  // final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllSittingPage(
      {Key? key, required this.articleDetails, required this.userRole})
      : super(key: key);

  @override
  State<AllSittingPage> createState() => _AllSittingPageState();
}

class _AllSittingPageState extends State<AllSittingPage> {
  List<Map<String, dynamic>> _foundDetails = [];

  // Map<String, Map<String, dynamic>> _foundDetails = {};

  @override
  initState() {
    _foundDetails = [];
    super.initState();
  }

  void _searchFunc(String articleNumber) {
    List<Map<String, dynamic>> results = [];
    // Map<String, Map<String, dynamic>> results = {};
    if (articleNumber.isEmpty) {
      results = widget.articleDetails;
    } else {
      results = widget.articleDetails.where((entry) {
        return entry['article_number'].contains(articleNumber);
      }).toList();
      print(results.length);
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
        backgroundColor: Colors.white,
        title: const Text('Sitting Samples Table'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              onChanged: (value) => _searchFunc(value),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                hintText: "Search Sitting Samples",
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
        ),
      ),
      body: ListView.builder(
        itemCount: _foundDetails.length,
        itemBuilder: (context, index) {
          // String key = _foundDetails.keys.elementAt(index);
          Map<String, dynamic> value = _foundDetails[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${languageProvider.translate('article_no')}: ${value['article_number']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${languageProvider.translate('similar')}: ${value["Similar"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('composition')}: ${value["Compo"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('texture')}: ${value["Texture"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('finish')}: ${value["Finish"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('usedwt')}: ${value["UsedWT"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('width')}: ${value["Width"]?.toString() ?? ""}'),
                  Text(
                      '${languageProvider.translate('color_code')}: ${value["ColorCode"]?.toString() ?? ""}'),
                  Text(
                      '${languageProvider.translate('e_color')}: ${value["E_Color"]?.toString() ?? ""}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('quantity')}: ${value["Quantity"]?.toString() ?? ""}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('unit')}: ${value["Unit"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('l1')}: ${value["L1"]?.toString() ?? ""}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('remark')}: ${value["Remark"]?.toString() ?? ""}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
