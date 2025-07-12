import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/report_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/profile_screen.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'repositories/user_repository.dart';
import 'models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  debugPrint('🔔 Requesting notification permissions...');
  var status = await Permission.notification.status;
  debugPrint('🔔 Current notification permission status: $status');

  if (!status.isGranted) {
    debugPrint('🔔 Permission not granted, requesting...');
    status = await Permission.notification.request();
    debugPrint('🔔 New permission status: $status');
  }

  if (status.isGranted) {
    debugPrint('✅ Notification permission granted');
  } else if (status.isDenied) {
    debugPrint('⚠️ Notification permission denied');
  } else if (status.isPermanentlyDenied) {
    debugPrint('❌ Notification permission permanently denied');
    // Show dialog explaining how to enable notifications from settings
    debugPrint('🔔 Opening app settings...');
    openAppSettings();
  }
}

// Fungsi untuk membuat akun user default jika belum ada
Future<void> createDefaultUserAccount() async {
  debugPrint('👤 Checking for default user account...');
  final userRepository = UserRepository();
  final String userEmail = 'user@gmail.com';
  final String userPassword = '12345';
  
  // Cek apakah akun user sudah ada
  final existingUser = await userRepository.getUserByEmail(userEmail);
  
  // Jika belum ada, buat akun user baru
  if (existingUser == null) {
    debugPrint('👤 Creating default user account...');
    final defaultUser = User(
      username: 'Default User',
      email: userEmail,
      password: userPassword,
      role: 'user',
    );
    
    await userRepository.createUser(defaultUser);
    debugPrint('✅ Default user account created');
  } else {
    debugPrint('✅ Default user account already exists');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi layanan notifikasi
  final notificationService = NotificationService();
  await notificationService.init();
  tz.initializeTimeZones();
  
  // Inisialisasi layanan autentikasi dan coba muat sesi pengguna
  final authService = AuthService();
  await authService.loadUserSession();
  
  // Buat akun user default jika belum ada
  await createDefaultUserAccount();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pengelola Waktu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        useMaterial3: true,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.blue),
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.blue,
        ),
      ),
      initialRoute: authService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tambah-tugas': (context) => const AddTaskScreen(),
        '/daftar-tugas': (context) => const TaskListScreen(),
        '/pengingat': (context) => const ReminderScreen(),
        '/laporan': (context) => const ReportScreen(),
        '/manajemen-user': (context) => const UserManagementScreen(),
        '/tambah-user': (context) => const UserManagementScreen(),
        '/edit-user': (context) => const UserManagementScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
