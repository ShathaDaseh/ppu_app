import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart' as home;
import 'screens/feeds_screen.dart';
import 'screens/login_screen.dart';

SharedPreferences ?sharedPref ;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref=await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PPU App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => home.HomeScreen(),
        '/feeds': (context) => FeedsScreen(),
       
      },
    );
  }
}