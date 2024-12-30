class Comment {
  final int id;
   String body;
  final DateTime datePosted;
  final String author;
  final int likesCount;
  bool isLiked;

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.author,
    required this.likesCount,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      datePosted: DateTime.parse(json['date_posted']),
      author: json['author'],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['liked'] ?? false,
    );
  }
}
