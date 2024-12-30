import 'package:flutter/material.dart';
import 'package:ppu_app/models/post.dart';
import 'package:ppu_app/screens/comment_screen.dart';

class PostCard extends StatelessWidget {
  
  final  Post post;
  final int courseId;
  final int sectionId;

  const PostCard({
    Key? key,
    required this.post,
    required this.sectionId,
    required this.courseId, required Null Function() onTap
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
              post.body,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              'By: ${post.author}',
              style: TextStyle(color:Color(0xFF4A1C2F)),
            ),
            SizedBox(height: 4),
            Text(
              'Posted on: ${post.datePosted}',
              style: TextStyle(color:Color(0xFF4A1C2F)),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return CommentFeedScreen(postId:post.id, courseId: courseId,sectionId: sectionId,);
                  },));
                }, child: Icon(Icons.comment, size: 16, color:Color(0xFF4A1C2F)),
                ),
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}