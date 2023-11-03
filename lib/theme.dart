import 'package:flutter/material.dart';

const seedColor = Color.fromARGB(255, 149, 10, 0);

final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);

const publicationDateStyle = TextStyle(
    fontStyle: FontStyle.italic, fontSize: 12.0, color: Colors.black45);

final themeData = ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
)
.copyWith(
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.background,
  ),
  tabBarTheme: TabBarTheme(
      labelColor: colorScheme.inversePrimary,
      unselectedLabelColor: colorScheme.inversePrimary
  ),
  listTileTheme: ListTileThemeData(
      titleTextStyle: TextStyle(
          color: colorScheme.onSurface, fontSize: 16.0, fontWeight: FontWeight.bold),
      subtitleTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14.0)),
    
);
