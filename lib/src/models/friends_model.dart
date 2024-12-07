class Friend {
  final int id;
  final String userName;

  Friend({
    required this.id,
    required this.userName,
  });

  // JSON 데이터를 Friend 객체로 변환
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json["id"] as int,
      userName: json["username"], // 서버에서 반환되는 키 이름
    );
  }

  // Friend 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": userName,
    };
  }
}

