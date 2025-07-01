class Reminder {
  final int? id;
  final int taskId;
  final DateTime waktuPengingat;
  final String tipePengingat; // 'notifikasi' atau 'email'

  Reminder({
    this.id,
    required this.taskId,
    required this.waktuPengingat,
    required this.tipePengingat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'waktuPengingat': waktuPengingat.millisecondsSinceEpoch,
      'tipePengingat': tipePengingat,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id']?.toInt(),
      taskId: map['taskId'],
      waktuPengingat: DateTime.fromMillisecondsSinceEpoch(
        map['waktuPengingat'],
      ),
      tipePengingat: map['tipePengingat'],
    );
  }
}
