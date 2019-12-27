import 'package:flutter/material.dart';
import 'package:flutter_reddit/post_details.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Reddit_app_demo',
        home: LoginPage(),
        routes: <String, WidgetBuilder>{
          '/landingpage': (BuildContext context) => new MyApp(),
          '/signup': (BuildContext context) => new SignupPage(),
          '/homepage': (BuildContext context) => new HomePage(),
          '/newsdetails': (BuildContext context) => new PostDetails(),
        });
  }
}
