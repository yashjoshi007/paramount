import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';

class AllExhibitPage extends StatefulWidget {
  final List<Map<String, dynamic>> articleDetails;
  // final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllExhibitPage(
      {Key? key, required this.articleDetails, required this.userRole})
      : super(key: key);

  @override
  State<AllExhibitPage> createState() => _AllExhibitPageState();
}

class _AllExhibitPageState extends State<AllExhibitPage> {
  List<Map<String, dynamic>> _foundDetails = [];

  @override
  initState() {
    _foundDetails = widget.articleDetails;
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
        title: const Text('Exhibit Data Table'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              onChanged: (value) => _searchFunc(value),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                hintText: "Search Exhibit",
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
                  Text('${languageProvider.translate('article_no')}: ${value['article_number']}',
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
}








// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AllExhibitPage extends StatefulWidget {
//   final Map<String, Map<String, dynamic>> articleDetails;
//   final String userRole;

//   const AllExhibitPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

//   @override
//   State<AllExhibitPage> createState() => _AllExhibitPageState();
// }

// class _AllExhibitPageState extends State<AllExhibitPage> {
//   List<MapEntry<String, Map<String, dynamic>>> _foundDetails = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _foundDetails = widget.articleDetails.entries.toList();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _searchFunc(String query) {
//     setState(() {
//       _foundDetails = widget.articleDetails.entries
//           .where((entry) => entry.key.contains(query))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Exhibit Data Table'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _searchFunc,
//               decoration: InputDecoration(
//                 contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 15),
//                 hintText: "Search Exhibit",
//                 hintStyle: GoogleFonts.poppins(
//                   color: Colors.grey,
//                   fontStyle: FontStyle.normal,
//                   fontSize: 14,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _foundDetails.length,
//               itemBuilder: (context, index) {
//                 final entry = _foundDetails[index];
//                 final key = entry.key;
//                 final value = entry.value;
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children: [
//                             Text(key),
//                             Text("Exhibit_Samples: ${value["Exhibit_Samples"] ?? "NA"}"),
//                             Text("Exhibit: ${value["Exhibit"] ?? "NA"}"),
//                             Text("Exhibit_Position: ${value["Exhibit_Position"] ?? "NA"}"),
//                             Text("Title: ${value["Title"] ?? "NA"}"),
//                             Text("SubTitle: ${value["SubTitle"] ?? "NA"}"),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }