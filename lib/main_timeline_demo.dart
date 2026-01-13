import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/timeline/presentation/screens/timeline_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Timeline Logger',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: TimelineScreen(tripId: '1'),
    );
  }
}
