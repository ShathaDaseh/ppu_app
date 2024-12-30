import 'package:flutter/material.dart';
import 'package:ppu_app/drawer.dart';
import 'package:ppu_app/main.dart';
import 'package:ppu_app/models/subscription.dart';
import 'package:ppu_app/widgets/course_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subscription> _subscribedCourses = [];
  bool _isLoading = true;
  String _username = ''; 

 _fetchSubscribedCourses() async {
  print('1');
    String? sessionToken = sharedPref?.getString('sessionToken');
    _username = sharedPref?.getString('username') ?? 'User'; 

    if (sessionToken == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final url = 'http://feeds.ppu.edu/api/v1/subscriptions'; 
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': '$sessionToken',
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          final res = responseData['subscriptions'] as List;
              _subscribedCourses= res.map((data) => Subscription.fromJson(data))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
    }
  }
  
  @override
  void initState() {
    super.initState();
    _fetchSubscribedCourses(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      drawer: AppDrawer(
        username: _username,
        onLogout: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('sessionToken');
          prefs.remove('username');
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: () async{
           await   _fetchSubscribedCourses();
            },
            child: ListView.builder(
                itemCount: _subscribedCourses.length,
                itemBuilder: (context, index) {
                  Subscription sub = _subscribedCourses[index];
            
                  return GestureDetector(
                    onTap: () {
                     
                    },
                    child: CourseCard(
                      course: sub.course,
                      courseName: sub.course,
                      section: sub.section,
                      lecturerName: sub.lecturer,
                      collegeName: "",
                      isSubscribed: true,
                      onSubscribeToggle: () {
            
                      },
                    ),
                  );
                },
              ),
          ),
    );
  }
}