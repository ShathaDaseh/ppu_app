import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_app/screens/section_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ppu_app/models/course.dart';
import 'package:ppu_app/widgets/course_card.dart';

class FeedsScreen extends StatefulWidget {
  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('sessionToken');

    if (sessionToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final url = 'http://feeds.ppu.edu/api/v1/courses';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
            print(responseData);

      setState(() {
        _courses = (responseData['courses'] as List)
            .map((data) => Course.fromJson(data))
            .toList();
        _isLoading = false;
      });
            print(_courses);

    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds Screen'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                Course course = _courses[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SectionScreen(courceId: course.id),));
                  },
                  child: CourseCard(
                    course: course,
                    courseName: course.name,
                    section: "",
                    lecturerName: "",
                    collegeName: course.college,
                    onSubscribeToggle: () {
               
                    },
                  ),
                );
              },
            ),
    );
  }
}