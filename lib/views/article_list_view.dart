import 'dart:typed_data';

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
  final Future<Uint8List> featureImageBytes;

  ArticleWithFeatureImage(
      {required this.article, required this.featureImageBytes});
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
            article: e, featureImageBytes: e.featureImageBytes()));

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
        final featureImageBytes = articleWithFeatureImage.featureImageBytes;

        final imageBuilder = FutureBuilder<Uint8List>(
            future: featureImageBytes,
            builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
              if (snapshot.hasError) {
                return const Text("Failed");
              }

              final showSkeleton = snapshot.data == null;

              final firstChild = Skeletonizer(
                  child: Container(
                width: leadingImageWidth,
                height: leadingImageHeight,
                color: Colors.black,
              ));

              final imageBytes = snapshot.data ?? Uint8List(0);

              final secondChild = imageBytes.isEmpty
                  ? Container(
                      width: leadingImageWidth,
                      height: leadingImageHeight,
                      color: const Color.fromARGB(255, 240, 240, 240),
                      child: const Center(child: Text("No Image")),
                    )
                  : Image.memory(
                      imageBytes,
                      width: leadingImageWidth,
                      height: leadingImageHeight,
                      fit: BoxFit.fill,
                    );

              return AnimatedCrossFade(
                  firstChild: firstChild,
                  secondChild: secondChild,
                  crossFadeState: showSkeleton
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(seconds: 1));
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
