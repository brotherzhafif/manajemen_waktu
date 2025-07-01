// filepath: c:\Users\u\Coding_Project\manajemen_waktu\lib\models\task_model.dart
class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String priority; // 'High', 'Medium', 'Low'
  final bool isCompleted;
  final int userId;

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

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      priority: map['priority'] ?? 'Medium',
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId']?.toInt() ?? 0,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? priority,
    bool? isCompleted,
    int? userId,
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