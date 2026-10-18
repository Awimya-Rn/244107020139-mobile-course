import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Clean Notes',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F7DC9),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}