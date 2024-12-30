import 'package:flutter/material.dart';
import 'package:ppu_app/models/comment.dart';
import 'package:ppu_app/widgets/commet_popup.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
    final int courceId;
  final int sectionId;
  final int postId;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.courceId,
    required this.sectionId,
    required this.postId,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) {
          return CommentPopup (comment: comment, courceId:courceId , postId: postId, sectionId: sectionId);
        },);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.body,
                style: TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                'Date Posted: ${comment.datePosted}',
                style: TextStyle(color: Color(0xFF4A1C2F)),
              ),
              Text(
                'By: ${comment.author}',
                style: TextStyle(color:Color(0xFF4A1C2F)),
              ),
              SizedBox(height: 8),
            ]
          ),
        ),
      ),
    );
  }
}
