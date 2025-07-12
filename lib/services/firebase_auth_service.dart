import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  static FirebaseAuthService get instance => _instance;

  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _auth = FirebaseService.instance.auth;
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream to listen to auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    DateTime? tanggalLahir,
  }) async {
    try {
      // Create user with email and password
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        final user = User(
          id: credential.user!.uid,
          username: username,
          email: email,
          tanggalLahir: tanggalLahir,
          role: 'user',
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toFirestore());

        _currentUser = user;
        return true;
      }
    } catch (e) {
      print('Sign up error: $e');
    }
    return false;
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserProfile();
        return true;
      }
    } catch (e) {
      print('Sign in error: $e');
    }
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  Future<void> _loadUserProfile() async {
    if (_auth.currentUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();

        if (doc.exists) {
          _currentUser = User.fromFirestore(doc);
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  Future<bool> loadUserSession() async {
    if (_auth.currentUser != null) {
      await _loadUserProfile();
      return true;
    }
    return false;
  }

  Future<bool> updateUserProfile(User user) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update(user.toFirestore());

        _currentUser = user;
        return true;
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }
    return false;
  }

  Future<bool> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        final userId = _auth.currentUser!.uid;

        // Delete user profile from Firestore
        await _firestore.collection('users').doc(userId).delete();

        // Delete all user's tasks
        final tasksQuery = await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in tasksQuery.docs) {
          await doc.reference.delete();
        }

        // Delete Firebase Auth account
        await _auth.currentUser!.delete();
        _currentUser = null;
        return true;
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
    return false;
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUsernameExists(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
