import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/report_screen.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/notification_debug_screen.dart';

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

void main() async {
  // Add debug log
  debugPrint('🚀 App starting...');

  // Ensure initialized before accessing native code
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ Flutter initialized');

  // Initialize notification service
  try {
    debugPrint('🔔 Initializing NotificationService...');
    await NotificationService().init();
    debugPrint('✅ NotificationService initialized');
  } catch (e) {
    debugPrint('❌ Error initializing NotificationService: $e');
  }

  // Request notification permission with enhanced logging
  try {
    debugPrint('🔔 Requesting notification permissions...');
    await requestNotificationPermission();
  } catch (e) {
    debugPrint('❌ Error requesting permissions: $e');
  }

  debugPrint('🚀 Starting app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tambah-tugas': (context) => const AddTaskScreen(),
        '/daftar-tugas': (context) => const TaskListScreen(),
        '/pengingat': (context) => const ReminderScreen(),
        '/laporan': (context) => const ReportScreen(),
        '/debug-notifikasi': (context) => const NotificationDebugScreen(),
      },
    );
  }
}
