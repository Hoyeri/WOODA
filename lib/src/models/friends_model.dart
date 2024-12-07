/// Friend 모델 클래스
class Friend {
  final int id;
  final String username;

  Friend({required this.id, required this.username});

  // JSON 데이터를 Friend 객체로 변환하는 생성자
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      username: json['username'],
    );
  }

  // Friend 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}