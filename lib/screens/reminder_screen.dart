import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
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

  Future<void> _deleteTask(int id) async {
    await TaskRepository().deleteTask(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada tugas di bulan ini.'),
                  );
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = tasks[i];
                    final date = t.startTime;
                    final hari = DateFormat('EEEE', 'id_ID').format(date);
                    final tanggal = DateFormat(
                      'd MMMM yyyy HH:mm',
                      'id_ID',
                    ).format(date);
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: Colors.orange,
                        ),
                        title: Text(
                          t.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$hari, $tanggal\nPrioritas: ${t.priority}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: const Text(
                                  'Apakah anda yakin ingin menghapus tugas ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await _deleteTask(t.id!);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
