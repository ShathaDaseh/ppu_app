class Like {
  final int likesCount;
  final bool liked;

  Like({required this.likesCount, required this.liked});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      likesCount: json['likes_count'],
      liked: json['liked'],
    );
  }
}