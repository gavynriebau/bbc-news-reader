import 'package:flutter/material.dart';
import 'home_page.dart';

const appBarColor = Color.fromARGB(255, 149, 10, 0);

final colorScheme = ColorScheme.fromSeed(seedColor: appBarColor);

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
        colorScheme: colorScheme,
        useMaterial3: true,
      ).copyWith(
          appBarTheme: AppBarTheme(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              titleTextStyle: const TextStyle(color: Colors.white))),
      home: const HomePage(title: 'Unofficial BBC News'),
    );
  }
}
