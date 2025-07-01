import '../models/user_model.dart';
import '../services/database_helper.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> createUser(User user) async {
    final db = await _databaseHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isEmailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> isUsernameExists(String username) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.isNotEmpty;
  }
}
