import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppu_app/main.dart';
import 'package:ppu_app/models/post.dart';
import 'package:ppu_app/screens/comment_screen.dart';
import 'dart:convert';
import 'package:ppu_app/widgets/post_card.dart';

class CourseFeedScreen extends StatefulWidget {
  final int courseId;
  final int section;

  const CourseFeedScreen({
    Key? key,
    required this.courseId,
    required this.section,
  }) : super(key: key);

  @override
  _CourseFeedScreenState createState() => _CourseFeedScreenState();
}

class _CourseFeedScreenState extends State<CourseFeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoursePosts();
  }

  Future<void> _fetchCoursePosts() async {
    String sessionToken = sharedPref?.getString('sessionToken') ?? "";

    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.section}/posts';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': sessionToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _posts = (responseData['posts'] as List)
              .map((data) => Post.fromJson(data))
              .toList();
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPost(String body) async {
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post cannot be empty')),
      );
      return;
    }

    String? sessionToken = sharedPref?.getString('sessionToken');
    final url =
        'http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.section}/posts';

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
        _fetchCoursePosts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post added successfully')),
        );
        _postController.clear();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Feed"),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      Post post = _posts[index];
                      return PostCard(
                        post: post,
                        courseId: widget.courseId,
                        sectionId: widget.section,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentFeedScreen(
                              postId: post.id,
                              courseId: widget.courseId,
                              sectionId: widget.section,
                            ),
                          ));
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _postController,
                          decoration: InputDecoration(
                            hintText: 'Enter new post',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit, color:Color(0xFF4A1C2F)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color:Color(0xFF4A1C2F)),
                        onPressed: () => _addPost(_postController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}