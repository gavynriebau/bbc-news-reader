import 'package:flutter/material.dart';
import 'article.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Center(
        child: Text("DetailsPage: $article.detailsUrl"),
      ),
    );
  }
}
