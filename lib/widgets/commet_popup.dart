import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_app/main.dart';
import 'package:ppu_app/models/comment.dart';
import 'package:http/http.dart' as http;

class CommentPopup extends StatefulWidget {
  final Comment comment;
  final int courceId;
  final int sectionId;
  final int postId;

  const CommentPopup(
      {Key? key,
      required this.comment,
      required this.courceId,
      required this.postId,
      required this.sectionId})
      : super(key: key);

  @override
  _CommentPopupState createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  bool _isLoading = false;
  bool isLike = false;
  int likeCount = 0;
  @override
  void initState() {
    
    super.initState();
    _isLoading = true;
    getData(widget.comment.id);
  }

  _getLikeCount(int commentId) async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courceId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        likeCount = responseData["likes_count"] ?? 0;
      });
    }
  }

  _getIsLike(int commentId) async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courceId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        isLike = responseData["liked"] as bool;
      });
    }
  }

  getData(int commentId) async {
    await _getLikeCount(commentId);
    await _getIsLike(commentId);
    setState(() {
      _isLoading = false;
    });
  }

  taggleLike(int commentId) async {
    String? sessionToken = sharedPref?.getString('sessionToken');

    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courceId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': '$sessionToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        if (isLike) {
          likeCount--;
        } else {
          likeCount++;
        }

        isLike = !isLike;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Comment comment = widget.comment;
    return SimpleDialog(
      children: [
        Container(
          child: Column(
            children: [
              ListTile(
                title: Text(comment.author),
                subtitle: Text(
                    "${widget.comment.datePosted.year}-${widget.comment.datePosted.month}-${widget.comment.datePosted.day}"),
                leading: CircleAvatar(
                  backgroundColor:Color(0xFF4A1C2F),
                  radius: 30,
                  child: Text(comment.author[0]),
                ),
              ),
              ListTile(
                title: Text(comment.body),
              ),
              Divider(),
              SizedBox(
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _isLoading
                        ? CircularProgressIndicator()
                        : Row(
                            children: [
                              Text(likeCount.toString()),
                              IconButton(
                                  onPressed: () {
                                    taggleLike(comment.id);
                                  },
                                  icon: Icon(isLike
                                      ? Icons.favorite
                                      : Icons.favorite_border))
                            ],
                          ),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
