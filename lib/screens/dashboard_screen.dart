import 'package:flutter/material.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'reminder_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<Task>> _tasksFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _checkUserSession();
  }
  
  Future<void> _checkUserSession() async {
    // Cek apakah ada sesi user yang tersimpan
    if (_authService.currentUser == null) {
      final hasSession = await _authService.loadUserSession();
      if (!hasSession && mounted) {
        // Jika tidak ada sesi, arahkan ke halaman login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    }
    _loadTasks();
  }

  void _loadTasks() {
    if (_authService.currentUser != null && _authService.currentUser!.id != null) {
      _tasksFuture = TaskRepository().getTasksByUserId(_authService.currentUser!.id!);
    } else {
      // Fallback jika tidak ada user yang login
      _tasksFuture = Future.value([]);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + delta);
      _loadTasks();
    });
  }

  Future<void> _toggleStatus(Task task) async {
    await TaskRepository().updateTask(
      task.copyWith(isCompleted: !task.isCompleted),
    );
    _loadTasks();
    setState(() {});
  }

  String _monthYearLabel(DateTime dt) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  // Widget untuk setiap tab
  Widget _buildHomeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.blue),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                _monthYearLabel(_activeMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.blue),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            children: [
              _StatusLegend(color: Colors.red, label: 'Pending'),
              const SizedBox(width: 16),
              _StatusLegend(color: Colors.green, label: 'Done'),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Tidak ada tugas.'));
              }
              final tasks = snapshot.data!
                  .where(
                    (t) =>
                        t.startTime.month == _activeMonth.month &&
                        t.startTime.year == _activeMonth.year,
                  )
                  .toList();
              if (tasks.isEmpty) {
                return const Center(
                  child: Text('Belum ada tugas di bulan ini.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = tasks[i];
                  final date = t.startTime;
                  final hari = DateFormat('EEEE', 'id_ID').format(date);
                  final tanggal = DateFormat(
                    'd MMMM yyyy',
                    'id_ID',
                  ).format(date).toUpperCase();
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () => _toggleStatus(t),
                        child: Icon(
                          Icons.circle,
                          color: t.isCompleted ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        t.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tanggal,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(hari, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: Checkbox(
                        value: t.isCompleted,
                        onChanged: (_) => _toggleStatus(t),
                        activeColor: Colors.green,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTab() {
    return const ReminderScreen();
  }

  Widget _buildReportTab() {
    return const ReportScreen();
  }

  Widget _buildProfileTab() {
    return const ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    String appBarTitle;
    if (_selectedIndex == 0) {
      body = _buildHomeTab();
      appBarTitle = 'Dashboard';
    } else if (_selectedIndex == 1) {
      body = _buildReminderTab();
      appBarTitle = 'Reminder';
    } else if (_selectedIndex == 2) {
      body = _buildReportTab();
      appBarTitle = 'Report';
    } else {
      body = _buildProfileTab();
      appBarTitle = 'Profil';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.blue,
        actions: [
          // IconButton(
          //   onPressed: () => _testNotification(),
          //   icon: const Icon(Icons.notifications_active),
          //   tooltip: 'Tes Notifikasi',
          // ),
          // Tambahkan menu untuk manajemen user dan debugging
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'admin',
                child: Text('Manajemen Pengguna'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onSelected: (value) {
              if (value == 'admin') {
                Navigator.pushNamed(context, '/admin-users');
              } else if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              tooltip: 'Tambah Tugas',
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/tambah-tugas',
                );
                if (result == true) {
                  _loadTasks();
                  setState(() {});
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminder',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Fungsi untuk menguji notifikasi
  Future<void> _testNotification() async {
    try {
      debugPrint('🔔 Mengirim notifikasi test...');

      // Kirim notifikasi langsung untuk testing
      await NotificationService().showNotification(
        id: 9999,
        title: 'Tes Notifikasi',
        body:
            'Jika Anda melihat notifikasi ini, sistem notifikasi berfungsi! ${DateTime.now().toString()}',
        sound: true,
        payload: 'test_notification',
      );

      // Juga kirim notifikasi terjadwal 10 detik dari sekarang
      final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
      await NotificationService().scheduleNotification(
        id: 9998,
        title: 'Tes Notifikasi Terjadwal',
        body:
            'Notifikasi terjadwal 10 detik. Waktu: ${scheduledTime.toString()}',
        scheduledTime: scheduledTime,
        sound: true,
        payload: 'test_scheduled',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifikasi test dikirim! Cek status bar atau tutup aplikasi untuk melihat.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error saat mengirim notifikasi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _StatusLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
