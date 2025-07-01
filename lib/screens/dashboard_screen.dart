import 'package:flutter/material.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'reminder_screen.dart';
import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadTasks();
  }

  void _loadTasks() {
    // Ganti userId sesuai login
    _tasksFuture = TaskRepository().getTasksByUserId(1);
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
        // Selector bulan
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                _monthYearLabel(_activeMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        // Statistik status
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
        // List tugas
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
              // Filter berdasarkan bulan aktif
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
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => _toggleStatus(t),
                      child: Icon(
                        Icons.circle,
                        color: t.isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(t.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tanggal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 0) {
      body = _buildHomeTab();
    } else if (_selectedIndex == 1) {
      body = _buildReminderTab();
    } else {
      body = _buildReportTab();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: body,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
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
              tooltip: 'Tambah Tugas',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
        ],
      ),
    );
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
