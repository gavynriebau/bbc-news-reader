import 'package:bbc_mobile/services/article_fetcher.dart';
import 'package:bbc_mobile/services/file_cached_article_fetcher.dart';
import 'package:bbc_mobile/services/rss_article_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'constants.dart';
import 'pages/home_page.dart';
import 'tab_details.dart';
import 'theme.dart';

void main() {
  registerDependencies();
  runApp(const UnofficialBbcApp());
}

void registerDependencies() {
  KiwiContainer container = KiwiContainer();

  //container.registerInstance<ArticleFetcher>((RssArticleFetcher());
  container.registerFactory<ArticleFetcher>(
      (c) => FileCachedArticleFetcher(articleFetcher: RssArticleFetcher()));
}

class UnofficialBbcApp extends StatelessWidget {
  const UnofficialBbcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: themeData,
      home: DefaultTabController(
        length: tabDetails.length,
        child: const HomePage(),
      ),
    );
  }
}
