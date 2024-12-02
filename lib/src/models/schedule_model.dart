class Schedule {
  final int id;
  final String writer;
  final String type; // "diary" or "schedule"
  final String title;
  final DateTime date;
  final String description;
  final String? image;

  Schedule({
    required this.id,
    required this.writer,
    required this.type,
    required this.title,
    required this.date,
    required this.description,
    this.image,
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
    };
  }
}
