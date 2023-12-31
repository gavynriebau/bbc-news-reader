import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:developer' as developer;

import '../article.dart';
import '../constants.dart';
import '../pages/details_page.dart';
import '../services/article_fetcher.dart';
import '../theme.dart';
import '../utils.dart';

KiwiContainer container = KiwiContainer();

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
  final articleFetcher = container.resolve<ArticleFetcher>();

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
            article: e,
            featureImageBytes: articleFetcher.featureImageBytes(e)));

    articles.sort((a, b) => parsePublicationDateToDateTime(b.publicationDate)
        .millisecondsSinceEpoch
        .compareTo(parsePublicationDateToDateTime(a.publicationDate)
            .millisecondsSinceEpoch));

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
                  ? Image.asset("assets/no_image.jpg",
                      width: leadingImageWidth,
                      height: leadingImageHeight,
                      fit: BoxFit.fill)
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
              Text(
                  dateTimeToDurationFromNow(
                      parsePublicationDateToDateTime(article.publicationDate)),
                  style: publicationDateStyle)
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
