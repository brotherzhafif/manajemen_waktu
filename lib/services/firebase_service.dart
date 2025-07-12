import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;

  FirebaseService._internal();

  late FirebaseFirestore _firestore;
  late firebase_auth.FirebaseAuth _auth;

  FirebaseFirestore get firestore => _firestore;
  firebase_auth.FirebaseAuth get auth => _auth;

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore = FirebaseFirestore.instance;
    _auth = firebase_auth.FirebaseAuth.instance;
  }

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get current user email
  String? get currentUserEmail => _auth.currentUser?.email;
}
