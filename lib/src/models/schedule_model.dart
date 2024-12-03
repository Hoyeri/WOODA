class Schedule {
  final int id;
  final String writer;
  final String type; // "diary" or "schedule"
  final String title;
  final DateTime date;
  final String description;
  final String? image;
  int likes; // 좋아요 수

  Schedule({
    required this.id,
    required this.writer,
    required this.type,
    required this.title,
    required this.date,
    required this.description,
    this.image,
    this.likes = 0, // 기본값 0
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map["id"],
      writer: map["writer"],
      type: map["type"],
      title: map["title"],
      date: map["date"],
      description: map["description"],
      image: map["image"],
      likes: map["likes"] ?? 0, // Map에서 좋아요 수를 가져오거나 기본값 0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "writer": writer,
      "type": type,
      "title": title,
      "date": date,
      "description": description,
      "image": image,
      "likes": likes, // 좋아요 수 저장
    };
  }
}

