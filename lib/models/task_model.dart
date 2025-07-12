// filepath: c:\Users\u\Coding_Project\manajemen_waktu\lib\models\task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id; // Changed from int? to String? for Firestore
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String priority; // 'High', 'Medium', 'Low'
  final bool isCompleted;
  final String userId; // Changed from int to String for Firebase Auth UID

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.priority,
    this.isCompleted = false,
    required this.userId,
  });

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'priority': priority,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      priority: data['priority'] ?? 'Medium',
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  // Legacy method for backward compatibility (can be removed later)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'userId': userId,
    };
  }

  // Legacy method for backward compatibility (can be removed later)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId']?.toString() ?? '',
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? priority,
    bool? isCompleted,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}
