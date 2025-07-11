class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final DateTime? tanggalLahir;
  final String role; // 'admin' atau 'user'

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.tanggalLahir,
    this.role = 'user', // Default role adalah 'user'
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'tanggal_lahir': tanggalLahir?.millisecondsSinceEpoch,
      'role': role,
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
      role: map['role'] ?? 'user',
    );
  }

  User copyWith({int? id, String? username, String? email, String? password, DateTime? tanggalLahir, String? role}) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      role: role ?? this.role,
    );
  }
}
