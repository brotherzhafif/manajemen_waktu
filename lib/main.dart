import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/report_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pengelola Waktu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
      },
    );
  }
}
