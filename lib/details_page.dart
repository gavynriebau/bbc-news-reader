import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Details"),
      ),
      body: const Center(
        child: Text("DetailsPage"),
      ),
    );
  }
}
