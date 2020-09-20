 

import 'package:driverojek/pages/home_page.dart';
import 'package:driverojek/splash.dart'; 
import 'package:flutter/material.dart';

import 'login.dart';
 
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
 
     
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: new HomePage(),
      home: SplashPage(),
        routes: <String, WidgetBuilder>{
          //'/task': (BuildContext context) => TaskPage(title: 'Task'),
          //'/home': (BuildContext context) => HomePage(title: 'Home'),
          //'/landingpage_view': (BuildContext context) => LandingPage(),
           '/home': (BuildContext context) => HomePage(),
           '/login': (BuildContext context) => LoginPage(),
          //'/register': (BuildContext context) => RegisterPage(),
          //'/register_hp': (BuildContext context) => RegisterHp(),
        }
    );
  }
}
