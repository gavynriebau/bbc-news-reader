import 'package:flutter/material.dart';
import 'article.dart';
import 'article_fetcher.dart';

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

  final fetcher = ArticleFetcher();

  @override
  void initState() {
    super.initState();
    fetchArticleContents();
  }

  void fetchArticleContents() async {
    final contents = await fetcher.contents(widget.article);
    setState(() {
      _contents = contents;
      _loading = false;
    });
  }

  Widget buildContents(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }

    return Text(_contents);
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
            Image.network(widget.article.imageUrl,
                alignment: Alignment.topCenter),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: padding),
              child: Text(widget.article.summary,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Container(
                margin: const EdgeInsets.all(padding),
                child: buildContents(context))
          ],
        ),
      ),
    );
  }
}
