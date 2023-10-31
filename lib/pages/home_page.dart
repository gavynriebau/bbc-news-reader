import 'package:flutter/material.dart';

import '../tab_details.dart';
import '../views/article_list_view.dart';
import '../constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          bottom:
              TabBar(tabs: [...tabDetails.map((e) => Tab(text: e.tabTitle))]),
        ),
        body: TabBarView(children: [
          ...tabDetails.map((e) => ArticleListView(rssUrl: e.rssUrl))
        ]));
  }
}
