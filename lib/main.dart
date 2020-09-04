import 'package:flutter/material.dart';
import 'package:flutter_chat/pages/otp_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './pages/group_info_page.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

import './pages/login_page.dart';
import './pages/registration_page.dart';
import './pages/home_page.dart';
import './pages/group_page.dart';


import './services/navigation_service.dart';

void main() {
  runApp(MyApp());

}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goose',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
        "group": (BuildContext _context) => GroupPage(),

      },
    );
  }
}
