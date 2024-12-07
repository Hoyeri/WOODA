class Item {
  final int id;
  final String user_id;
  final String type; // "diary" or "schedule"
  final String title;
  final DateTime date;
  final String description;
  final String? image;
  int likes; // 좋아요 수

  Item({
    required this.id,
    required this.user_id,
    required this.type,
    required this.title,
    required this.date,
    required this.description,
    this.image,
    this.likes = 0, // 기본값 0
  });

  // JSON 데이터를 Item 객체로 변환
  factory Item.fromJson(Map<String, dynamic> json) {
    print("변환 중인 JSON 데이터: $json");
    try {
      return Item(
        id: json["id"],
        user_id: json["user_id"].toString(),
        type: json["type"] as String,
        title: json["title"] as String,
        date: DateTime.parse(json["date"]),
        description: json["description"] as String,
        image: json["image"] != null ? json["image"] as String : null,
        likes: json["likes"] ?? 0,
      );
    } catch (e) {
      print("Item 변환 오류: $e, 문제의 JSON 데이터: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": user_id,
      "type": type,
      "title": title,
      "date": date,
      "description": description,
      "image": image,
      "likes": likes, // 좋아요 수 저장
    };
  }
}

