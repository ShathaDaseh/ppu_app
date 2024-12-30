import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_app/main.dart';
import 'package:ppu_app/models/section.dart';
import 'package:ppu_app/models/subscription.dart';
import 'package:ppu_app/screens/course_feed_screen.dart';
import 'package:ppu_app/widgets/course_card.dart';

class SectionScreen extends StatefulWidget {
  const SectionScreen({Key? key, required this.courceId}) : super(key: key);
  final int courceId;

  @override
  _SectionScreenState createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  List<Section> _section = [];
  List<Subscription> _sub = [];
  List<int> _subSection = [];
  bool _isLoading = false;

  Future<void> _fetchCoursesSection() async {
    String sessionToken = sharedPref?.getString('sessionToken') ?? "";

    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courceId}/sections';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': '$sessionToken',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);

        final responseData = json.decode(response.body)["sections"] as List;
        setState(() {
          _section = responseData
              .map(
                (e) => Section.fromJson(e),
              )
              .toList();
        });
      } else {}
    } catch (error) {}
  }

  _fetchSubscribed() async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    try {
      final url = 'http://feeds.ppu.edu/api/v1/subscriptions';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': '$sessionToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final res = responseData['subscriptions'] as List;
        _sub = res.map((data) => Subscription.fromJson(data)).toList();
        _sub.forEach(
          (element) {
            if (element.course == _section[0].course) {
              _subSection.add(element.sectionid);
            }
          },
        );
        print(_subSection);
        setState(() {
          _section.forEach(
            (element) {
              if (_subSection.contains(element.id)) {
                element.isSub = true;
              }
            },
          );
        });
      } else {}
    } catch (error) {}
  }

  Future<void> _subscribeToCourse(int courseId, int section) async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    final url =
        'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$section/subscribe';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscribed successfully')),
      );
      setState(() {
        _section.forEach(
          (element) {
            if (element.id == section) {
              element.isSub = true;
            }
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to subscribe')),
      );
    }
  }

  Future<void> _unsubscribeFromCourse(
      int courseId, int section, int subId) async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    final url =
        'http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$section/subscribe/$subId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsubscribed successfully')),
      );
      setState(() {
        _section.forEach(
          (element) {
            if (element.id == section) {
              element.isSub = false;
            }
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsubscribe')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getData();
    setState(() {
      _isLoading = false;
    });
  }

  getData() async {
    await _fetchCoursesSection();
    await _fetchSubscribed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sections"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _section.length,
              itemBuilder: (context, index) {
                Section section = _section[index];

                int subid = 0;
                _sub.forEach(
                  (element) {
                    if (element.sectionid == section.id) {
                      subid = element.id;
                    }
                  },
                );
                print(index);
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return CourseFeedScreen(courseId: widget.courceId, section: section.id);
                    },));
                  },
                  child: CourseCard(
                      courseName: section.course,
                      section: section.name,
                      lecturerName: section.lecturer,
                      collegeName: "IT",
                      isSubscribed: section.isSub,
                      onSubscribeToggle: () {
                        if (section.isSub) {
                          _unsubscribeFromCourse(
                              widget.courceId, section.id, subid);
                        } else {
                          _subscribeToCourse(widget.courceId, section.id);
                        }
                      },
                      course: ""),
                );
              },
            ),
    );
  }
}
