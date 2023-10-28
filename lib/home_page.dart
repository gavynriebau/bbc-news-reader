import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'article.dart';
import 'article_fetcher.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  final _articles = <Article>[];

  final articleFetcher = ArticleFetcher();

  @override
  void initState() {
    super.initState();
    populateArticles();
  }

  Future<void> populateArticles() async {
    final articles = await articleFetcher.fetch();
    final numArticles = articles.length;

    developer.log("Fetched $numArticles articles");

    setState(() {
      _articles.addAll(articles);
      _loading = false;
    });
  }

  Widget buildListViewForArticles(BuildContext context) {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];

        final titleStyle = const TextStyle(fontWeight: FontWeight.bold)
            .merge(Theme.of(context).listTileTheme.titleTextStyle);

        return ListTile(
          leading:
              Image.network(article.imageUrl, alignment: Alignment.topCenter),
          title: Text(
            article.title,
            style: titleStyle,
          ),
          subtitle: Text(article.summary,
              style: Theme.of(context).listTileTheme.subtitleTextStyle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailsPage(article: article))
                );
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _loading
        ? const CircularProgressIndicator()
        : buildListViewForArticles(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: center,
      ),
    );
  }
}
