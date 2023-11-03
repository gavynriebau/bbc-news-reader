import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';

import '../article.dart';
import '../services/article_fetcher.dart';

const padding = 16.0;

KiwiContainer container = KiwiContainer();

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.article});

  final Article article;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _loading = true;
  String _contents = "";
  Uint8List _imageBytes = Uint8List(0);

  final articleFetcher = container.resolve<ArticleFetcher>();

  @override
  void initState() {
    super.initState();
    fetchArticleContents();
  }

  void fetchArticleContents() async {
    final contents = await articleFetcher.contents(widget.article);
    final imageBytes = await articleFetcher.featureImageBytes(widget.article);
    setState(() {
      _contents = contents;
      _imageBytes = imageBytes;
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

    if (_imageBytes.isEmpty) {
      return null;
    }

    return Image.memory(_imageBytes, alignment: Alignment.topCenter);
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
