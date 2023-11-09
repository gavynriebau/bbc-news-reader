import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import '../article.dart';
import '../constants.dart';
import 'article_fetcher.dart';

class RssArticleFetcher implements ArticleFetcher {
  final Map<String, Future<Document>> _cacheArticleUrlToDocument = {};

  @override
  Future<List<Article>> fetchFromRssFeed(String rssUrl) async {
    developer.log("Fetching articles from RSS feed '$rssUrl'...");

    final articles = <Article>[];
    final response = await http.get(Uri.parse(rssUrl));

    final statusCode = response.statusCode;
    developer.log("response.statusCode = $statusCode");

    if (statusCode == 200) {
      final document = parse(response.body);

      final html = document.outerHtml;
      developer.log("Fetched html = $html");

      final elements = document.querySelectorAll('channel > item');

      // Title and subtitle are wrapped in a CDATA tag.
      RegExp cdataRegex = RegExp(r'.*\[CDATA\[(.*)\]\].*');

      for (var element in elements) {
        final titleRaw = element.querySelector('title')?.nodes.first.text;
        final subtitleRaw =
            element.querySelector('description')?.nodes.first.text;
        final url = element.querySelector('guid')?.text;
        final pubDate = element.querySelector('pubDate')?.text;

        if (titleRaw == null ||
            subtitleRaw == null ||
            url == null ||
            pubDate == null) {
          developer.log(
              "Failed to parse document as it was missing a required element");
          continue;
        }

        final titleMatch = cdataRegex.firstMatch(titleRaw);
        final title = titleMatch?.group(1);

        final subtitleMatch = cdataRegex.firstMatch(subtitleRaw);
        final subtitle = subtitleMatch?.group(1);

        if (title == null || subtitle == null) {
          developer.log(
              "Failed to parse document as it was missing a required element");
          continue;
        }

        final article = Article(
            title: title,
            summary: subtitle,
            detailsUrl: url,
            publicationDate: pubDate);

        articles.add(article);
      }
    }

    return articles;
  }

  @override
  Future<Uint8List> featureImageBytes(Article article) async {
    final featureImageUrl = await this.featureImageUrl(article);

    if (featureImageUrl.isEmpty) {
      return Uint8List(0);
    }

    final response = await http.get(Uri.parse(featureImageUrl));

    if (response.statusCode != 200) {
      return Uint8List(0);
    }

    return response.bodyBytes;
  }

  @override
  Future<String> featureImageUrl(Article article) async {
    final document = await _document(article);

    final featureImageBlock = document
        .querySelectorAll(
            '#main-content > article > [data-component=image-block] img')
        .cast<Element?>()
        .firstWhere((Element? element) {
      final heightAttr = element?.attributes["height"] ?? "0";
      final height = int.tryParse(heightAttr) ?? 0;

      return height >= minHeightForValidImages;
    }, orElse: () => null);

    return featureImageBlock?.attributes["src"] ?? "";
  }

  @override
  Future<List<ContentItem>> contents(Article article) async {
    final contentItems = List<ContentItem>.empty(growable: true);

    final document = await _document(article);
    final blocks =
        document.querySelectorAll('#main-content > article > [data-component]');

    for (var block in blocks) {
      final componentType = block.attributes['data-component'];

      if (componentType == "text-block") {
        contentItems.add(
            ContentItem(contentType: ContentType.text, contents: block.text));
      }

      if (componentType == "image-block") {
        final img = await _getImageElement(block);
        final src = img?.attributes["src"] ?? "";
        if (src.isNotEmpty) {
          final heightText = img?.attributes["height"] ?? "0";
          final height = int.tryParse(heightText) ?? 0;
          if (height >= minHeightForValidImages) {
            developer.log("Added image-block with src: $src");
            contentItems.add(
                ContentItem(contentType: ContentType.image, contents: src));
          }
        }
      }

      if (componentType == "byline-block") {
        final divs = block.querySelectorAll('div');
        final innerMostDivs = divs.where((e) => e.children.isEmpty);
        final innerMostText =
            innerMostDivs.map((e) => e.text.trim()).where((e) => e.isNotEmpty);
        final text = innerMostText.join("\n");
        developer.log("Adding byline-block with text: $text");
        contentItems
            .add(ContentItem(contentType: ContentType.byline, contents: text));
      }
    }

    return contentItems;
  }

  Future<Element?> _getImageElement(Element block) async {
    Element? img = block.querySelector('picture > img');

    if (img == null) {
      final noScript = block.querySelector('noscript');
      if (noScript != null) {
        final html = noScript.innerHtml;
        final document = await compute(parse, html);

        img = document.querySelector('picture > img');
      }
    }

    return img;
  }

  Future<Document> _document(Article article) async {
    final articleUrl = article.detailsUrl;

    final document =
        _cacheArticleUrlToDocument.putIfAbsent(articleUrl, () async {
      final html = await _fetchHtml(article);
      final document = compute(parse, html);

      return document;
    });

    return await document;
  }

  Future<String> _fetchHtml(Article article) async {
    String html = "<empty>";

    final response = await http.get(Uri.parse(article.detailsUrl));

    if (response.statusCode == 200) {
      html = response.body;
    }

    return html;
  }
}
