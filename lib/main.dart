import 'package:flutter/material.dart';
import 'package:onetap/router.dart';
import 'package:onetap/view/loginPage.dart';
import 'package:onetap/view/registerPage.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(
          elevation: 5.0
        ),
        scaffoldBackgroundColor: Color(0xFFfafafa)
      ),
    );
  }
}