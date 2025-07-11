import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final UserRepository _userRepository = UserRepository();
  User? _currentUser;

  AuthService._internal();

  factory AuthService() => _instance;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  
  // Metode untuk memperbarui data user saat ini
  Future<void> updateCurrentUser(User user) async {
    _currentUser = user;
    await _saveUserSession(user);
  }

  Future<bool> login(String email, String password) async {
    final user = await _userRepository.authenticateUser(email, password);
    if (user != null) {
      _currentUser = user;
      await _saveUserSession(user);
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password, {DateTime? tanggalLahir, String role = 'user'}) async {
    // Check if email or username already exists
    if (await _userRepository.isEmailExists(email)) {
      return false;
    }
    if (await _userRepository.isUsernameExists(username)) {
      return false;
    }

    final user = User(
      username: username, 
      email: email, 
      password: password,
      tanggalLahir: tanggalLahir,
      role: role
    );

    try {
      final userId = await _userRepository.createUser(user);
      _currentUser = user.copyWith(id: userId);
      await _saveUserSession(_currentUser!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('role', user.role);
    
    // Simpan tanggal lahir jika ada
    if (user.tanggalLahir != null) {
      await prefs.setInt('tanggalLahir', user.tanggalLahir!.millisecondsSinceEpoch);
    }
  }

  Future<bool> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final role = prefs.getString('role') ?? 'user';
    final tanggalLahirMillis = prefs.getInt('tanggalLahir');
    
    DateTime? tanggalLahir;
    if (tanggalLahirMillis != null) {
      tanggalLahir = DateTime.fromMillisecondsSinceEpoch(tanggalLahirMillis);
    }

    if (userId != null && username != null && email != null) {
      _currentUser = User(
        id: userId,
        username: username,
        email: email,
        password: '', // Don't store password in session
        tanggalLahir: tanggalLahir,
        role: role,
      );
      return true;
    }
    return false;
  }
}
