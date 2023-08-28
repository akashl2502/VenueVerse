import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Getstarted.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Appcolor.firstgreen, primary: Appcolor.firstgreen),
        useMaterial3: true,
      ),
      home: Getstarted(),
    );
  }
}
