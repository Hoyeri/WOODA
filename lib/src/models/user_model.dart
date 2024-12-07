/// User 모델 클래스
class User {
  final int id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  // JSON 데이터를 User 객체로 변환하는 생성자
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
    );
  }

  // User 객체를 JSON 데이터로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }
}
