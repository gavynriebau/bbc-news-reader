import 'package:bbc_mobile/article.dart';
import 'package:bbc_mobile/services/article_fetcher.dart';
import 'package:flutter/foundation.dart';

class FileCachedArticleFetcher implements ArticleFetcher {
  final ArticleFetcher articleFetcher;

  FileCachedArticleFetcher({ required this.articleFetcher });

  @override
  Future<String> contents(Article article) {
    return articleFetcher.contents(article);
  }

  @override
  Future<Uint8List> featureImageBytes(Article article) {
    return articleFetcher.featureImageBytes(article);
  }

  @override
  Future<String> featureImageUrl(Article article) {
    return articleFetcher.featureImageUrl(article);
  }

  @override
  Future<List<Article>> fetchFromRssFeed(String rssUrl) {
    return articleFetcher.fetchFromRssFeed(rssUrl);
  }
}