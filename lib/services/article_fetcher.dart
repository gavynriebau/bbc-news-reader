import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';

import '../article.dart';

abstract class ArticleFetcher {
  Future<List<Article>> fetchFromRssFeed(String rssUrl);
  Future<Uint8List> featureImageBytes(Article article);
  Future<String> featureImageUrl(Article article);
  Future<String> contents(Article article);
  Future<Document> document(Article article);
}
