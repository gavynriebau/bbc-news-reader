import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'package:share_plus/share_plus.dart';

import '../article.dart';
import '../services/article_fetcher.dart';

const padding = 16.0;
const paddingEdgeInsets = EdgeInsets.fromLTRB(padding, padding, padding, 0);
const paddingTopInsetOnly = EdgeInsets.fromLTRB(0, padding, 0, 0);

KiwiContainer container = KiwiContainer();

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.article});

  final Article article;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _loading = true;
  List<ContentItem> _contents = List.empty();

  final articleFetcher = container.resolve<ArticleFetcher>();

  @override
  void initState() {
    super.initState();
    fetchArticleContents();
  }

  void fetchArticleContents() async {
    final contents = await articleFetcher.contents(widget.article);

    setState(() {
      _contents = contents;
      _loading = false;
    });
  }

  Widget buildContents(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final contents = _contents
        .map((x) => switch (x.contentType) {
              ContentType.text => Container(
                  margin: paddingEdgeInsets,
                  child: Row(
                    children: [Expanded(child: Text(x.contents))],
                  )),
              ContentType.image => Container(
                  margin: paddingTopInsetOnly,
                  child: Row(
                    children: [
                      Expanded(
                          child: Image.network(
                        x.contents,
                        fit: BoxFit.fill,
                      ))
                    ],
                  )),
              ContentType.byline => Container(
                  margin: paddingEdgeInsets,
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _buildBylineWidgetsFromText(context, x.contents),
                      ))
                    ],
                  ))
            })
        .nonNulls
        .toList();

    contents.insertAll(0, [
      Container(
        margin: paddingEdgeInsets,
        child: Text(widget.article.title,
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      Container(
        margin: paddingEdgeInsets,
        child: Text(widget.article.summary,
            style: Theme.of(context).textTheme.titleMedium),
      ),
    ]);

    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
          child: Column(children: contents.nonNulls.toList())),
    );
  }

  List<Widget> _buildBylineWidgetsFromText(BuildContext context, String text) {
    final widgets = List<Widget>.empty(growable: true);

    for (var (idx, val) in text.split('\n').indexed) {
      final style = switch (idx) {
        0 => Theme.of(context).textTheme.labelLarge,
        _ => null
      };

      widgets.add(Text(val, style: style));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
          actions: [
            IconButton(
                onPressed: () {
                  Share.shareUri(Uri.parse(widget.article.detailsUrl));
                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: buildContents(context));
  }
}
