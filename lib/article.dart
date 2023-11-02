import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class Article {
  final String title;
  final String summary;
  final String detailsUrl;
  final String publicationDate;
  Future<String>? _html;

  Article(
      {required this.title, required this.summary, required this.detailsUrl, required this.publicationDate });

  Future<String> _fetchHtml() async {
    String html = "<empty>";

    final response = await http.get(Uri.parse(detailsUrl));

    if (response.statusCode == 200) {
      html = response.body;
    }

    return html;
  }

  Future<String> html() async {
    _html ??= _fetchHtml();
    return _html!;
  }

  Future<Document> _document() async {
    final html = await this.html();
    final document = await compute(parse, html);

    return document;
  }

  Future<String> contents() async {
    final document = await _document();
    final textBlocks = document.querySelectorAll(
        '#main-content > article > [data-component=text-block]');
    final contents = textBlocks.map((e) => e.text).join("\n\n");

    return contents;
  }

  Future<String> featureImageUrl() async {
    final document = await _document();
    final featureImageBlock = document
        .querySelectorAll(
            '#main-content > article > [data-component=image-block] img')
        .firstOrNull;

    return featureImageBlock?.attributes["src"] ?? "";
  }

  Future<Uint8List> featureImageBytes() async {
    final featureImageUrl = await this.featureImageUrl();

    if (featureImageUrl.isEmpty) {
      return Uint8List(0);
    }

    final response = await http.get(Uri.parse(featureImageUrl));

    if (response.statusCode != 200) {
      return Uint8List(0);
    }

    return response.bodyBytes;
  }
}
