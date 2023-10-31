import 'dart:ffi';

import 'package:flutter/material.dart';
import '../article.dart';

const padding = 16.0;

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.article});

  final Article article;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _loading = true;
  String _contents = "";
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchArticleContents();
  }

  void fetchArticleContents() async {
    final contents = await widget.article.contents();
    final imageUrl = await widget.article.featureImageUrl();
    setState(() {
      _contents = contents;
      _imageUrl = imageUrl;
      _loading = false;
    });
  }

  Widget buildContents(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }

    return Text(_contents);
  }

  Widget? buildImage(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }

    if (_imageUrl.isEmpty) {
      return null;
    }

    return Image.network(_imageUrl, alignment: Alignment.topCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: padding),
              child: Text(widget.article.title,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            buildImage(context),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: padding),
              child: Text(widget.article.summary,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Container(
                margin: const EdgeInsets.all(padding),
                child: buildContents(context))
          ].nonNulls.toList(),
        ),
      ),
    );
  }
}
