import 'package:bbc_mobile/services/article_fetcher.dart';
import 'package:bbc_mobile/services/file_cached_article_fetcher.dart';
import 'package:bbc_mobile/services/rss_article_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart';
import 'constants.dart';
import 'pages/home_page.dart';
import 'services/old_file_cleanup.dart';
import 'tab_details.dart';
import 'theme.dart';

void main() {
  registerDependencies();
  runApp(const UnofficialBbcApp());
}

void registerDependencies() {
  KiwiContainer container = KiwiContainer();

  container.registerFactory<ArticleFetcher>(
      (c) => FileCachedArticleFetcher(articleFetcher: RssArticleFetcher()));
}

class UnofficialBbcApp extends StatefulWidget {
  const UnofficialBbcApp({super.key});

  @override
  State<StatefulWidget> createState() => _UnofficialBbcAppState();
}

class _UnofficialBbcAppState extends State<UnofficialBbcApp> {

  @override
  void initState() {
    super.initState();
    cleanOldCacheFiles();
  }

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
