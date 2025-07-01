import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../repositories/reminder_repository.dart';
import '../models/task_model.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<ReminderWithTask>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadReminders();
  }

  void _loadReminders() {
    // Ganti userId sesuai login
    _remindersFuture = ReminderRepository().getRemindersWithTaskByMonth(
      1,
      _activeMonth,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + delta);
      _loadReminders();
    });
  }

  Future<void> _deleteReminder(int id) async {
    await ReminderRepository().deleteReminder(id);
    _loadReminders();
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
      appBar: AppBar(title: const Text('Pengingat')),
      body: Column(
        children: [
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
          Expanded(
            child: FutureBuilder<List<ReminderWithTask>>(
              future: _remindersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pengingat di bulan ini.'),
                  );
                }
                final reminders = snapshot.data!;
                return ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, i) {
                    final r = reminders[i];
                    final date = r.reminder.waktuPengingat;
                    final hari = DateFormat('EEEE', 'id_ID').format(date);
                    final tanggal = DateFormat(
                      'd MMMM yyyy',
                      'id_ID',
                    ).format(date);
                    return ListTile(
                      title: Text(r.task?.title ?? '(Tugas dihapus)'),
                      subtitle: Text('$hari, $tanggal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteReminder(r.reminder.id!),
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
    // Model untuk join reminder dan task
    // ReminderWithTask is now imported from the repository.
  }
}
