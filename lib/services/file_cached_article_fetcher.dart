import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../article.dart';
import '../content_item.dart';
import 'article_fetcher.dart';

const MAX_AGE_OF_RSS_FEED_IN_MINS = 5;

class FileCachedArticleFetcher implements ArticleFetcher {
  final ArticleFetcher articleFetcher;

  FileCachedArticleFetcher({required this.articleFetcher});

  Future<File> _getCacheFileForKey(String cacheKey, String suffix) async {
    final Directory cacheDirectory = await getApplicationCacheDirectory();
    final cacheFilePath =
        [cacheDirectory.absolute.path, "${cacheKey}_$suffix"].join('/');
    final cacheFile = File(cacheFilePath);

    return cacheFile;
  }

  Future<File> _getCacheFileForArticle(Article article, String suffix) async {
    final articleSha = _sha1OfArticle(article);
    return _getCacheFileForKey(articleSha, suffix);
  }

  Future<File> _getCacheFileForRssUrl(String rssUrl, String suffix) async {
    final articleSha = _sha1OfString(rssUrl);
    return _getCacheFileForKey(articleSha, suffix);
  }

  @override
  Future<List<ContentItem>> contents(Article article) async {
    final cacheFile = await _getCacheFileForArticle(article, "contents");

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
    final cacheFile = await _getCacheFileForArticle(article, "image_bytes");

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
    final cacheFile = await _getCacheFileForArticle(article, "image_url");

    if (await cacheFile.exists()) {
      return await cacheFile.readAsString();
    }

    final imageUrl = await articleFetcher.featureImageUrl(article);
    if (imageUrl.isNotEmpty) {
      await cacheFile.writeAsString(imageUrl, flush: true);
    }

    return imageUrl;
  }

  Future<bool> _canUseRssFeedCacheFile(File cacheFile) async {
    if (!await cacheFile.exists()) {
      return false;
    }

    final modified = (await cacheFile.stat()).modified;
    final now = DateTime.now();
    final duration = now.difference(modified);

    final tooOld = duration.inMinutes > MAX_AGE_OF_RSS_FEED_IN_MINS;

    if (tooOld) {
      return false;
    }

    return true;
  }

  @override
  Future<List<Article>> fetchFromRssFeed(String rssUrl) async {
    final cacheFile = await _getCacheFileForRssUrl(rssUrl, "rss_feed");

    if (await _canUseRssFeedCacheFile(cacheFile)) {
      final json = await cacheFile.readAsString();
      final items = jsonDecode(json) as List<dynamic>;
      return items
          .cast<Map<String, dynamic>>()
          .map((e) => Article.fromJson(e))
          .toList();
    }

    final articles = await articleFetcher.fetchFromRssFeed(rssUrl);
    if (articles.isNotEmpty) {
      final json = jsonEncode(articles);
      await cacheFile.writeAsString(json, flush: true);
    }

    return articles;
  }

  String _sha1OfArticle(Article article) {
    return _sha1OfString(article.detailsUrl);
  }

  String _sha1OfString(String text) {
    final bytes = utf8.encode(text);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
