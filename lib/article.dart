import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  DateTime publicationDateTime() {
    final format = DateFormat("EEE, dd MMM y H:m:s 'GMT'");
    final dateTime = format.parse(publicationDate);

    return dateTime;
  }

  /// Converts the publicationDate from a format such as "Sat, 28 Oct 2023 12:35:08 GMT" to
  /// a duration relative to now, e.g. "2 days 11 hours ago".
  String publicationDuration() {
    final dateTime = publicationDateTime();
    final now = DateTime.now();

    Duration duration = now.difference(dateTime);

    final parts = <String>[];

    final days = duration.inDays;
    if (days > 0) {
      parts.add("$days days");
      duration -= Duration(days: days);
    }
    final hours = duration.inHours;
    if (hours > 0) {
      parts.add("$hours hours");
      duration -= Duration(hours: hours);
    }
    final minutes = duration.inMinutes;
    if (minutes > 0) {
      parts.add("$minutes minutes");
      duration -= Duration(minutes: minutes);
    }

    parts.add("ago");

    final text = parts.join(" ");
    
    return text;
  }
}
