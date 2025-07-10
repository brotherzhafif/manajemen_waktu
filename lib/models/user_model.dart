class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final DateTime? tanggalLahir;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.tanggalLahir,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'tanggal_lahir': tanggalLahir?.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt(),
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      tanggalLahir: map['tanggal_lahir'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['tanggal_lahir']) 
          : null,
    );
  }

  User copyWith({int? id, String? username, String? email, String? password, DateTime? tanggalLahir}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
    );
  }
}
