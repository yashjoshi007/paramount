import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';

class AllArticlePage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllArticlePage(
      {Key? key, required this.articleDetails, required this.userRole})
      : super(key: key);

  @override
  State<AllArticlePage> createState() => _AllArticlePageState();
}

class _AllArticlePageState extends State<AllArticlePage> {
  Map<String, Map<String, dynamic>> _foundDetails = {};

  @override
  initState() {
    _foundDetails = {};
    super.initState();
  }

  void _searchFunc(String articleNumber) {
    Map<String, Map<String, dynamic>> results = {};
    if (articleNumber.isEmpty) {
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
        ),
      ),
      body: ListView.builder(
        itemCount: _foundDetails.length,
        itemBuilder: (context, index) {
          String key = _foundDetails.keys.elementAt(index);
          Map<String, dynamic> value = _foundDetails[key]!;
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${languageProvider.translate('article_no')}: $key',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${languageProvider.translate('composition')}: ${value["Compo"]?.toString() ?? "NA"}'),
                  Text(
                      '${languageProvider.translate('texture')}: ${value["Texture"]?.toString() ?? "NA"}'),
                  Text(
                      '${languageProvider.translate('finish')}: ${value["Finish"]?.toString() ?? "NA"}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('density')}: ${value["Density"]?.toString() ?? "NA"}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('yarn_count')}: ${value["Yarn_Count"]?.toString() ?? "NA"}'),
                  Text(
                      '${languageProvider.translate('full_width')}: ${value["Width"]?.toString() ?? "NA"}'),
                  Text(
                      '${languageProvider.translate('weight')}: ${value["Weight"]?.toString() ?? "NA"}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('price_usd')}: ${value["Price_D"]?.toString() ?? "NA"}'),
                  if (widget.userRole == 'colleague' ||
                      widget.userRole == 'Colleague')
                    Text(
                        '${languageProvider.translate('price_yen')}: ${value["Price_Y"]?.toString() ?? "NA"}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
