import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:share_plus/share_plus.dart';

import '../article.dart';
import '../services/article_fetcher.dart';

const padding = 16.0;
const paddingEdgeInsets = EdgeInsets.fromLTRB(padding, padding, padding, 0);

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
  Uint8List _imageBytes = Uint8List(0);

  final articleFetcher = container.resolve<ArticleFetcher>();

  @override
  void initState() {
    super.initState();
    fetchArticleContents();
  }

  void fetchArticleContents() async {
    final contents = await articleFetcher.contents(widget.article);
    final imageBytes = await articleFetcher.featureImageBytes(widget.article);
    setState(() {
      _contents = contents;
      _imageBytes = imageBytes;
      _loading = false;
    });
  }

  List<Widget> buildContents(BuildContext context) {
    if (_loading) {
      return [
        Container(
            margin: paddingEdgeInsets, child: const CircularProgressIndicator())
      ];
    }

    return _contents
        .map((x) => switch (x.contentType) {
              ContentType.text => Row(
                  children: [Expanded(child: Text(x.contents))],
                ),
              ContentType.image => Row(
                  children: [
                    Expanded(
                        child: Image.network(
                      x.contents,
                      fit: BoxFit.fill,
                    ))
                  ],
                ),
              ContentType.byline => Row(
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _buildBylineWidgetsFromText(context, x.contents),
                    ))
                  ],
                )
            })
        .map((e) => Container(margin: paddingEdgeInsets, child: e))
        .nonNulls
        .toList();
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

  Widget? buildImage(BuildContext context) {
    Widget? child;

    if (_loading) {
      child = Skeletonizer(
          enabled: true,
          child: Container(
            width: 100.0,
            height: 200.0,
            color: Colors.white,
          ));
    } else if (_imageBytes.isNotEmpty) {
      child = Image.memory(_imageBytes, alignment: Alignment.topCenter);
    }

    if (child == null) {
      return null;
    }

    return Row(children: [Expanded(child: child)]);
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
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, padding),
            child: Column(
              children: [
                Container(
                  margin: paddingEdgeInsets,
                  child: Text(widget.article.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                // Padding(padding: paddingEdgeInsets, child: buildImage(context)),
                Container(
                  margin: paddingEdgeInsets,
                  child: Text(widget.article.summary,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                ...buildContents(context),
              ].nonNulls.toList(),
            )),
      ),
    );
  }
}
