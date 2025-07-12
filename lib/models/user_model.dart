import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id; // Changed from int? to String? for Firebase Auth UID
  final String username;
  final String email;
  final String? password; // Made optional since Firebase handles auth
  final DateTime? tanggalLahir;
  final String role; // Always 'user' - admin functionality removed

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.tanggalLahir,
    this.role = 'user', // Default role adalah 'user'
  });

  // Convert to Firestore format (for user profile data)
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'tanggalLahir': tanggalLahir != null
          ? Timestamp.fromDate(tanggalLahir!)
          : null,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      tanggalLahir: data['tanggalLahir'] != null
          ? (data['tanggalLahir'] as Timestamp).toDate()
          : null,
      role: data['role'] ?? 'user',
    );
  }

  // Legacy methods for backward compatibility
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
      id: map['id']?.toString(),
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      tanggalLahir: map['tanggal_lahir'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['tanggal_lahir'])
          : null,
      role: map['role'] ?? 'user',
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    DateTime? tanggalLahir,
    String? role,
  }) {
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
