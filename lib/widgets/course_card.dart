import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String courseName;
  final String section;
  final String lecturerName;
  final String collegeName;
  final bool ?isSubscribed;
  final VoidCallback onSubscribeToggle;

  const CourseCard({
    Key? key,
    required this.courseName,
    required this.section,
    required this.lecturerName,
    required this.collegeName,
     this.isSubscribed,
    required this.onSubscribeToggle,
    required Object course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Section: $section'),
            Text('Lecturer: $lecturerName'),
            collegeName == '' ? Container() : Text('College: $collegeName'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
               isSubscribed==null?Container(): IconButton(
                  icon: Icon(
                    isSubscribed! ? Icons.star : Icons.star_border,
                    color: isSubscribed! ? Colors.yellow : Color(0xFF4A1C2F),
                  ),
                  onPressed: onSubscribeToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
