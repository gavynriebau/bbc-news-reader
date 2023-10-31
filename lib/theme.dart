import 'package:flutter/material.dart';

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
    tabBarTheme: const TabBarTheme(
        labelColor: Colors.white, unselectedLabelColor: Colors.white));
