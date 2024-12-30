class Section {
  final int id;
  final String name;
  final String course;
  final String lecturer;
  bool isSub;

  Section({
    required this.id,
    required this.name,
    required this.course,
    required this.lecturer,
    this.isSub=false
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      course: json['course'],
      lecturer: json['lecturer'],
    );
  }
}