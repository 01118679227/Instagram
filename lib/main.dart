import 'package:flutter/material.dart';
import 'package:insta/pages/HomePage.dart';
import 'package:insta/pages/profilePage.dart';
import 'package:insta/pages/searchPage.dart';
import 'package:insta/pages/uploadPage.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuddiesGram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        cardColor: Colors.white70,
        accentColor: Colors.black,
      ),
      home: HomePage(),
    );
  }
}
