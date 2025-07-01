import '../models/task_model.dart';
import '../services/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> createTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasksByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'startTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByDate(int userId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final maps = await db.query(
      'tasks',
      where: 'userId = ? AND startTime >= ? AND startTime <= ?',
      whereArgs: [
        userId,
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'startTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markTaskAsCompleted(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasks',
      {'isCompleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> getCompletedTasks(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = 1',
      whereArgs: [userId],
      orderBy: 'endTime DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getPendingTasks(int userId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'userId = ? AND isCompleted = 0',
      whereArgs: [userId],
      orderBy: 'startTime ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }
}
