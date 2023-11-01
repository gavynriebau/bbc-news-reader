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

  Future<String> contents() async {
    final html = await this.html();
    final document = parse(html);
    final textBlocks = document.querySelectorAll(
        '#main-content > article > [data-component=text-block]');
    final contents = textBlocks.map((e) => e.text).join("\n\n");

    return contents;
  }

  Future<String> featureImageUrl() async {
    final html = await this.html();
    final document = parse(html);
    final featureImageBlock = document
        .querySelectorAll(
            '#main-content > article > [data-component=image-block] img')
        .firstOrNull;

    return featureImageBlock?.attributes["src"] ?? "";
  }
}
