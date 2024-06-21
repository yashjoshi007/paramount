import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/language_provider.dart';
import 'package:provider/provider.dart';
// import '../../components/myBtn.dart';

class SittingDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> articleDetails;
  final String userRole;
  final String barcode; // Assuming user role is passed to this widget

  const SittingDetailsPage({Key? key, required this.articleDetails, required this.userRole, required this.barcode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Sitting Details',style:GoogleFonts.poppins()),
      ),
      body: ListView.builder(
        itemCount: articleDetails.length,
        itemBuilder: (context, index) {
          // String key = articleDetails.keys.elementAt(index);
          Map<String, dynamic> value = articleDetails[index];
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
                  if (userRole == 'colleague' || userRole == 'Colleague')Text(
                      '${languageProvider.translate('quantity')}: ${value["Quantity"]?.toString() ?? ""}'),
                  if (userRole == 'colleague' || userRole == 'Colleague') Text(
                      '${languageProvider.translate('unit')}: ${value["Unit"]?.toString() ?? ""}'),
                  // Text(
                  //     '${languageProvider.translate('l1')}: ${value["L1"]?.toString() ?? ""}'),
                  if (userRole == 'colleague' || userRole == 'Colleague')Text(
                      '${languageProvider.translate('remark')}: ${value["Remark"]?.toString() ?? ""}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

//   DataRow _buildDetailRow(String title, String value) {
//     return DataRow(cells: [
//       DataCell(Text(title,style:GoogleFonts.poppins())),
//       DataCell(Text(value,style:GoogleFonts.poppins())),
//     ]);
//   }
}
