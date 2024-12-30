class Subscription {
  final int id;
  final String section;
  final int sectionid;
  final String course;
  final String lecturer;
  final DateTime subscriptionDate;


  Subscription({
    required this.id,
    required this.section,
    required this.course,
    required this.lecturer,
    required this.subscriptionDate,
    required this.sectionid
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      section: json['section'],
      course: json['course'],
      lecturer: json['lecturer'],
      subscriptionDate: DateTime.parse(json['subscription_date']),
      sectionid: json['section_id'] as int,
    );
  }
}