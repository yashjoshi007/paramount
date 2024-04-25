import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> articleDetails;

  const ArticleDetailsPage({Key? key, required this.articleDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Article No: ${articleDetails['Article_No']}'),
            Text('Composition: ${articleDetails['Compo']}'),
            Text('Texture: ${articleDetails['Texture']}'),
            Text('Finish: ${articleDetails['Finish']}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}