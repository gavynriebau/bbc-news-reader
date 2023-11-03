import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../article.dart';
import 'article_fetcher.dart';

class FileCachedArticleFetcher implements ArticleFetcher {
  final ArticleFetcher articleFetcher;

  FileCachedArticleFetcher({required this.articleFetcher});

  Future<File> _getCacheFile(Article article, String suffix) async {
    final Directory cacheDirectory = await getApplicationCacheDirectory();
    final articleSha = _sha1(article);
    final cacheFilePath =
        [cacheDirectory.absolute.path, "${articleSha}_$suffix"].join('/');
    final cacheFile = File(cacheFilePath);

    return cacheFile;
  }

  @override
  Future<List<ContentItem>> contents(Article article) async {
    final cacheFile = await _getCacheFile(article, "contents");

    if (await cacheFile.exists()) {
      final json = await cacheFile.readAsString();
      final items = jsonDecode(json) as List<dynamic>;
      return items
          .cast<Map<String, dynamic>>()
          .map((e) => ContentItem.fromJson(e))
          .toList();
    }

    final contents = await articleFetcher.contents(article);
    if (contents.isNotEmpty) {
      final json = jsonEncode(contents);
      await cacheFile.writeAsString(json, flush: true);
    }

    return contents;
  }

  @override
  Future<Uint8List> featureImageBytes(Article article) async {
    final cacheFile = await _getCacheFile(article, "image_bytes");

    if (await cacheFile.exists()) {
      return await cacheFile.readAsBytes();
    }

    final imageBytes = await articleFetcher.featureImageBytes(article);
    if (imageBytes.isNotEmpty) {
      await cacheFile.writeAsBytes(imageBytes, flush: true);
    }

    return imageBytes;
  }

  @override
  Future<String> featureImageUrl(Article article) async {
    final cacheFile = await _getCacheFile(article, "image_url");

    if (await cacheFile.exists()) {
      return await cacheFile.readAsString();
    }

    final imageUrl = await articleFetcher.featureImageUrl(article);
    if (imageUrl.isNotEmpty) {
      await cacheFile.writeAsString(imageUrl, flush: true);
    }

    return imageUrl;
  }

  @override
  Future<List<Article>> fetchFromRssFeed(String rssUrl) {
    return articleFetcher.fetchFromRssFeed(rssUrl);
  }

  String _sha1(Article article) {
    final bytes = utf8.encode(article.detailsUrl);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
