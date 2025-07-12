import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'firebase_service.dart';

class FirebaseTaskRepository {
  static final FirebaseTaskRepository _instance =
      FirebaseTaskRepository._internal();
  static FirebaseTaskRepository get instance => _instance;

  FirebaseTaskRepository._internal();

  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  // Create a new task
  Future<String?> createTask(Task task) async {
    try {
      final docRef = await _firestore
          .collection('tasks')
          .add(task.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating task: $e');
      return null;
    }
  }

  // Get all tasks for a user
  Future<List<Task>> getTasksByUserId(String userId) async {
    try {
      print('🔍 TaskRepository: Fetching tasks for user ID: $userId');
      final query = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      print('🔍 TaskRepository: Found ${query.docs.length} tasks');
      List<Task> tasks = query.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();

      // Sort manually to avoid composite index requirement
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

      return tasks;
    } catch (e) {
      print('❌ Error getting tasks: $e');
      return [];
    }
  }

  // Get tasks by date
  Future<List<Task>> getTasksByDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final query = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where(
            'startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      List<Task> tasks = query.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();

      // Sort manually to avoid composite index requirement
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

      return tasks;
    } catch (e) {
      print('Error getting tasks by date: $e');
      return [];
    }
  }

  // Update a task
  Future<bool> updateTask(Task task) async {
    try {
      if (task.id != null) {
        await _firestore
            .collection('tasks')
            .doc(task.id!)
            .update(task.toFirestore());
        return true;
      }
    } catch (e) {
      print('Error updating task: $e');
    }
    return false;
  }

  // Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Mark task as completed
  Future<bool> markTaskAsCompleted(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': true,
      });
      return true;
    } catch (e) {
      print('Error marking task as completed: $e');
      return false;
    }
  }

  // Get completed tasks
  Future<List<Task>> getCompletedTasks(String userId) async {
    try {
      final query = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('endTime', descending: true)
          .get();

      return query.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting completed tasks: $e');
      return [];
    }
  }

  // Get pending tasks
  Future<List<Task>> getPendingTasks(String userId) async {
    try {
      final query = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('startTime', descending: false)
          .get();

      return query.docs.map((doc) => Task.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting pending tasks: $e');
      return [];
    }
  }

  // Stream tasks for real-time updates
  Stream<List<Task>> streamTasksByUserId(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }
}
