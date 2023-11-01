import 'package:flutter/material.dart';

const appBarColor = Color.fromARGB(255, 149, 10, 0);

final colorScheme = ColorScheme.fromSeed(seedColor: appBarColor);

const publicationDateStyle = TextStyle(
    fontStyle: FontStyle.italic, fontSize: 12.0, color: Colors.black45);

final themeData = ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
).copyWith(
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primary,
    foregroundColor: Colors.white,
  ),
  tabBarTheme: const TabBarTheme(
      labelColor: Colors.white, unselectedLabelColor: Colors.white),
  listTileTheme: const ListTileThemeData(
      titleTextStyle: TextStyle(
          color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
      subtitleTextStyle: TextStyle(color: Colors.black87, fontSize: 14.0)),
);
