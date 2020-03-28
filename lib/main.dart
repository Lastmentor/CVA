import 'package:flutter/material.dart';
import 'package:flutter_app_cva/ui/Introduction.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CVA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: TutorialScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}