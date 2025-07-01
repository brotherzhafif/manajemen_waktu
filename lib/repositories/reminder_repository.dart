import '../models/reminder_model.dart';
import '../models/task_model.dart';
import '../services/database_helper.dart';

import 'task_repository.dart';
import 'package:sqflite/sqflite.dart';

class ReminderRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> createReminder(Reminder reminder) async {
    final db = await _databaseHelper.database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getRemindersByUserAndMonth(
    int userId,
    DateTime month,
  ) async {
    final db = await _databaseHelper.database;
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final maps = await db.rawQuery(
      '''
      SELECT reminders.* FROM reminders
      JOIN tasks ON reminders.taskId = tasks.id
      WHERE tasks.userId = ? AND reminders.waktuPengingat >= ? AND reminders.waktuPengingat <= ?
      ORDER BY reminders.waktuPengingat ASC
    ''',
      [userId, firstDay.millisecondsSinceEpoch, lastDay.millisecondsSinceEpoch],
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<ReminderWithTask>> getRemindersWithTaskByMonth(
    int userId,
    DateTime month,
  ) async {
    final reminders = await getRemindersByUserAndMonth(userId, month);
    final taskRepo = TaskRepository();
    List<ReminderWithTask> result = [];
    for (final r in reminders) {
      Task? task;
      try {
        final db = await _databaseHelper.database;
        final maps = await db.query(
          'tasks',
          where: 'id = ?',
          whereArgs: [r.taskId],
        );
        if (maps.isNotEmpty) {
          task = Task.fromMap(maps.first);
        }
      } catch (_) {}
      result.add(ReminderWithTask(reminder: r, task: task));
    }
    return result;
  }

  Future<int> deleteReminder(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}

// Model join Reminder + Task
class ReminderWithTask {
  final Reminder reminder;
  final Task? task;
  ReminderWithTask({required this.reminder, required this.task});
}
