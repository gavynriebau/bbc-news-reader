import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:transparent_image/transparent_image.dart';

import '../article.dart';
import '../article_fetcher.dart';
import '../pages/details_page.dart';

class ArticleWithFeatureImage {
  final Article article;
  final Future<String> featureImageUrl;

  ArticleWithFeatureImage(
      {required this.article, required this.featureImageUrl});
}

class ArticleListView extends StatefulWidget {
  final String rssUrl;

  const ArticleListView({super.key, required this.rssUrl});

  @override
  State<ArticleListView> createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  bool _loading = true;
  final _articles = <ArticleWithFeatureImage>[];
  final articleFetcher = ArticleFetcher();

  @override
  void initState() {
    super.initState();
    populateArticles();
  }

  Future<void> populateArticles() async {
    final articles = await articleFetcher.fetchFromRssFeed(widget.rssUrl);
    final articlesWithFeatureImages = articles.map((e) {
      return ArticleWithFeatureImage(
          article: e, featureImageUrl: e.featureImageUrl());
    });
    final numArticles = articles.length;

    developer.log("Fetched $numArticles articles");

    setState(() {
      _articles.addAll(articlesWithFeatureImages);
      _loading = false;
    });
  }

  Widget buildListViewForArticles(BuildContext context) {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final articleWithFeatureImage = _articles[index];
        final article = articleWithFeatureImage.article;
        final featureImageUrl = articleWithFeatureImage.featureImageUrl;

        final titleStyle = const TextStyle(fontWeight: FontWeight.bold)
            .merge(Theme.of(context).listTileTheme.titleTextStyle);

        final imageBuilder = FutureBuilder<String>(
            future: featureImageUrl,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) {
                return const Text("Failed");
              }

              final imageUrl = snapshot.data ?? "";
              if (imageUrl.isEmpty) {
                return const Placeholder();
              }

              return FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imageUrl,
                  width: 100,
                  height: 100,
                  repeat: ImageRepeat.repeat,
                  );
            });

        return ListTile(
          // leading: imageBuilder,
          leading: SizedBox(
            width: 100,
            height: 100,
            child: Center(child: imageBuilder),
          ),
          isThreeLine: true,
          title: Text(
            article.title,
            style: titleStyle,
          ),
          subtitle: Text(article.summary,
              style: Theme.of(context).listTileTheme.subtitleTextStyle),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(article: article)));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const CircularProgressIndicator()
        : buildListViewForArticles(context);

    return Center(child: content);
  }
}
