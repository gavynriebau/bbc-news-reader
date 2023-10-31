import 'package:flutter/material.dart';
import 'constants.dart';
import 'pages/home_page.dart';
import 'theme.dart';

void main() {
  runApp(const UnofficialBbcApp());
}

class UnofficialBbcApp extends StatelessWidget {
  const UnofficialBbcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: themeData,
      home: const DefaultTabController(
        length: 2,
        child: HomePage(),
      ),
    );
  }
}
