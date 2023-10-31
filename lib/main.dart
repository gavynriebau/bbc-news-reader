import 'package:flutter/material.dart';
import 'home_page.dart';

const appBarColor = Color.fromARGB(255, 149, 10, 0);

final colorScheme = ColorScheme.fromSeed(seedColor: appBarColor);

final themeData = ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
).copyWith(
    appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        ),
    tabBarTheme: const TabBarTheme(labelColor: Colors.white,
        unselectedLabelColor: Colors.white
    ));

void main() {
  runApp(const UnofficialBbcApp());
}

class UnofficialBbcApp extends StatelessWidget {
  const UnofficialBbcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BBC News Reader',
      theme: themeData,
      home: const DefaultTabController(
        length: 2,
        child: HomePage(title: 'BBC News Reader'),
      ),
    );
  }
}
