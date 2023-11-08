import 'package:flutter/foundation.dart';

import '../article.dart';

enum ContentType { text, image, byline }

class ContentItem {
  final ContentType contentType;
  final String contents;

  ContentItem({required this.contentType, required this.contents});

  Map<String, dynamic> toJson() {
    return {'contentType': contentType.name, 'contents': contents};
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final contentTypeText = json['contentType'] as String;
    final contentType = switch (contentTypeText) {
      "text" => ContentType.text,
      "image" => ContentType.image,
      _ => ContentType.text
    };
    final contents = json['contents'] as String;

    return ContentItem(contentType: contentType, contents: contents);
  }
}

abstract class ArticleFetcher {
  Future<List<Article>> fetchFromRssFeed(String rssUrl);
  Future<Uint8List> featureImageBytes(Article article);
  Future<String> featureImageUrl(Article article);
  Future<List<ContentItem>> contents(Article article);
}
