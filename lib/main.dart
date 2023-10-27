import 'package:bbc_mobile/article_fetcher.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

const appBarColor = Color.fromARGB(255, 149, 10, 0);

void main() {
  runApp(const UnofficialBbcApp());
}

class UnofficialBbcApp extends StatelessWidget {
  const UnofficialBbcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unofficial BBC News App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appBarColor),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Unofficial BBC News'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  final _articles = <Article>[];

  final articleFetcher = ArticleFetcher();

  @override
  void initState() {
    super.initState();
    populateArticles();
  }

  Future<void> populateArticles() async {
    final articles = await articleFetcher.fetch();

    final numArticles = articles.length;
    developer.log("Fetched $numArticles articles");

    setState(() {
      _articles.addAll(articles);
      _loading = false;
    });
  }

  Widget buildListViewForArticles(BuildContext context) {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];

        final titleStyle = const TextStyle(fontWeight: FontWeight.bold)
            .merge(Theme.of(context).listTileTheme.titleTextStyle);

        return ListTile(
          leading:
              Image.network(article.imageUrl, alignment: Alignment.topCenter),
          title: Text(
            article.title,
            style: titleStyle,
          ),
          subtitle: Text(article.summary,
              style: Theme.of(context).listTileTheme.subtitleTextStyle),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _loading
        ? const CircularProgressIndicator()
        : buildListViewForArticles(context);

    final appBarTitleTextStyle = const TextStyle(color: Colors.white)
        .merge(Theme.of(context).appBarTheme.titleTextStyle);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(widget.title, style: appBarTitleTextStyle),
      ),
      body: Center(
        child: center,
      ),
    );
  }
}
