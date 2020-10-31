import 'package:alkitabtb/pages/awal.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Nunito'),
      home: AwalPage(
        initialIndex: 0,
      ),
    );
  }
}
