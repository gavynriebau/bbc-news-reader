import 'package:bbc_mobile/article_fetcher.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
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
  int _counter = 0;
  final _articles = <Article>[];

  final articleFetcher = ArticleFetcher();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
    });
  }

  @override
  Widget build(BuildContext context) {

    final columns = _articles.map((a) => Text(a.title));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ...columns
          ],
        ),
      ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
