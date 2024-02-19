import 'package:flutter/foundation.dart';
import '../article.dart';
import '../content_item.dart';

abstract class ArticleFetcher {
  Future<List<Article>> fetchFromRssFeed(String rssUrl);
  Future<Uint8List> featureImageBytes(Article article);
  Future<String> featureImageUrl(Article article);
  Future<List<ContentItem>> contents(Article article);
}
