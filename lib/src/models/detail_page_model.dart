class DetailPageModel {
  final String title;
  final String description;
  final DateTime date;
  final String? image;

  DetailPageModel({
    required this.title,
    required this.description,
    required this.date,
    this.image,
  });

  /// JSON 데이터를 DetailPageModel로 변환
  factory DetailPageModel.fromJson(Map<String, dynamic> json) {
    return DetailPageModel(
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      image: json['image'],
    );
  }

  /// DetailPageModel을 JSON 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'image': image,
    };
  }
}
