import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import 'article.dart';

class ArticleFetcher {
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
      RegExp cdataRegex = RegExp(r'<!\[CDATA\[(.*)\]\]>');

      for (var element in elements) {
        final titleRaw = element.querySelector('title')?.text;
        final subtitleRaw = element.querySelector('description')?.text;
        final url = element.querySelector('guid')?.text;

        if (titleRaw == null || subtitleRaw == null || url == null) {
          developer.log(
              "Failed to parse document as it was missing a required element");
          continue;
        }

        final titleMatch = cdataRegex.firstMatch(titleRaw);
        final title = titleMatch?.group(1);

        final subtitleMatch = cdataRegex.firstMatch(titleRaw);
        final subtitle = subtitleMatch?.group(1);

        if (title == null || subtitle == null) {
          developer.log(
              "Failed to parse document as it was missing a required element");
          continue;
        }

        final article = Article(
            title: title, summary: subtitle, detailsUrl: url);

        articles.add(article);
      }
    }

    return articles;
  }

}
