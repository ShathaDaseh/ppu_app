import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_app/main.dart';
import 'dart:convert';

class CommentFeedScreen extends StatefulWidget {
  final int postId;
  final int courseId;
  final int sectionId;

  const CommentFeedScreen({
    Key? key,
    required this.postId,
    required this.courseId,
    required this.sectionId,
  }) : super(key: key);

  @override
  _CommentFeedScreenState createState() => _CommentFeedScreenState();
}

class _CommentFeedScreenState extends State<CommentFeedScreen> {
  List<dynamic> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken!,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _comments = (responseData['comments'] as List)
              .map((data) => {
                    'id': data['id'],
                    'body': data['body'],
                    'datePosted': data['date_posted'],
                    'author': data['author'],
                    'likesCount': data['likes_count'] ?? 0,
                    'liked': data['liked'] ?? false,
                  })
              .toList();
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching comments')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment(String body) async {
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({'body': body}),
      );

      if (response.statusCode == 201) {
        _fetchComments();
        _commentController.clear();
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment')),
      );
    }
  }

  Future<void> _updateComment(int commentId, String body) async {
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken!,
          'Content-Type': 'application/json',
        },
        body: json.encode({'body': body}),
      );

      if (response.statusCode == 200) {
        _fetchComments();
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating comment')),
      );
    }
  }

  Future<void> _deleteComment(int commentId) async {
    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken!,
        },
      );

      if (response.statusCode == 200) {
        _fetchComments();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment')),
      );
    }
  }

  Future<void> _toggleLike(int commentId, bool isLiked) async {
    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken!,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _comments = _comments.map((comment) {
            if (comment['id'] == commentId) {
              comment['liked'] = !isLiked;
              comment['likesCount'] += isLiked ? -1 : 1;
            }
            return comment;
          }).toList();
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling like')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['body'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'By: ${comment['author']}',
                                style: TextStyle(color: Color(0xFF4A1C2F)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Posted on: ${comment['datePosted']}',
                                style: TextStyle(color: Color(0xFF4A1C2F)),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      comment['liked']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: comment['liked']
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _toggleLike(
                                      comment['id'],
                                      comment['liked'],
                                    ),
                                  ),
                                  Text('${comment['likesCount']} Likes'),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _commentController.text = comment['body'];
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Update Comment'),
                                          content: TextField(
                                            controller: _commentController,
                                            decoration: InputDecoration(
                                                hintText: 'Enter comment'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => _updateComment(
                                                comment['id'],
                                                _commentController.text,
                                              ),
                                              child: Text('Update'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteComment(
                                      comment['id'],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _commentController.clear();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Add Comment'),
                          content: TextField(
                            controller: _commentController,
                            decoration:
                                InputDecoration(hintText: 'Enter comment'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => _addComment(
                                _commentController.text,
                              ),
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Add Comment'),
                  ),
                ),
              ],
            ),
    );
  }
}