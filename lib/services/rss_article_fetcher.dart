import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import '../article.dart';
import 'article_fetcher.dart';

class RssArticleFetcher implements ArticleFetcher {
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
        .firstOrNull;

    return featureImageBlock?.attributes["src"] ?? "";
  }

  @override
  Future<String> contents(Article article) async {
    final document = await _document(article);
    final textBlocks = document.querySelectorAll(
        '#main-content > article > [data-component=text-block]');
    final contents = textBlocks.map((e) => e.text).join("\n\n");

    return contents;
  }

  Future<Document> _document(Article article) async {
    final html = await _fetchHtml(article);
    final document = await compute(parse, html);

    return document;
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
