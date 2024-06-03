import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllExhibitPage extends StatefulWidget {
  final Map<String, Map<String, dynamic>> articleDetails;
  final String userRole; // Assuming user role is passed to this widget

  const AllExhibitPage({Key? key, required this.articleDetails, required this.userRole}) : super(key: key);

  @override
  State<AllExhibitPage> createState() => _AllExhibitPageState();
}

class _AllExhibitPageState extends State<AllExhibitPage> {

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
      title: const Text('Exhibit Data Table'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const[
                  DataColumn(label: Text('Article No')),
                  DataColumn(label: Text('Exhibit_Samples')),
                  DataColumn(label: Text('Exhibit')),
                  DataColumn(label: Text('Exhibit_Position')),
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('SubTitle')),
                ],
                rows: _foundDetails.entries.map((entry) {
                  String key = entry.key;
                  Map<String, dynamic> value = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(key)),
                      DataCell(Text(value["Exhibit_Samples"] ?? "NA")),
                      DataCell(Text(value["Exhibit"] ?? "NA")),
                      DataCell(Text(value["Exhibit_Position"] ?? "NA")),
                      DataCell(Text(value["Title"] ?? "NA")),
                      DataCell(Text(value["SubTitle"] ?? "NA")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        
      ],
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