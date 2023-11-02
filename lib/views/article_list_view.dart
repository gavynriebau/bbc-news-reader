import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:developer' as developer;

import '../article.dart';
import '../article_fetcher.dart';
import '../constants.dart';
import '../pages/details_page.dart';
import '../theme.dart';

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

    if (!mounted) {
      return;
    }

    final articlesWithFeatureImages = articles.map((e) =>
        ArticleWithFeatureImage(
            article: e, featureImageUrl: e.featureImageUrl()));

    articles.sort((a, b) => b
        .publicationDateTime()
        .millisecondsSinceEpoch
        .compareTo(a.publicationDateTime().millisecondsSinceEpoch));

    final numArticles = articles.length;
    developer.log("Fetched $numArticles articles");

    setState(() {
      _articles.addAll(articlesWithFeatureImages);
      _loading = false;
    });
  }

  Future<void> _refreshArticles() async {
    setState(() {
      _articles.clear();
      _loading = true;
    });

    await populateArticles();
  }

  Widget buildListViewForArticles(BuildContext context) {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final articleWithFeatureImage = _articles[index];
        final article = articleWithFeatureImage.article;
        final featureImageUrl = articleWithFeatureImage.featureImageUrl;

        final imageBuilder = FutureBuilder<String>(
            future: featureImageUrl,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) {
                return const Text("Failed");
              }

              final showSkeleton = snapshot.data == null;

              if (showSkeleton) {
                return Skeletonizer(
                    child: Container(
                  width: leadingImageWidth,
                  height: leadingImageHeight,
                  color: Colors.black,
                ));
              }

              final imageUrl = snapshot.data ?? "";

              if (imageUrl.isEmpty) {
                return Container(
                  width: leadingImageWidth,
                  height: leadingImageHeight,
                  color: const Color.fromARGB(255, 240, 240, 240),
                  child: const Center(child: Text("No Image")),
                );
              }

              return Image.network(
                imageUrl,
                width: leadingImageWidth,
                height: leadingImageHeight,
                fit: BoxFit.fill,
              );
            });

        return ListTile(
          isThreeLine: true,
          leading: SizedBox(
            width: leadingImageWidth,
            height: leadingImageHeight,
            child: FittedBox(fit: BoxFit.fill, child: imageBuilder),
          ),
          title: Text(article.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(article.summary),
              Text(article.publicationDuration(), style: publicationDateStyle)
            ],
          ),
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
        : RefreshIndicator(
            onRefresh: _refreshArticles,
            child: buildListViewForArticles(context),
          );

    return Center(child: content);
  }
}
