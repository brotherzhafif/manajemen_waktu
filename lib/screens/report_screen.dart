import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/firebase_task_repository.dart';
import '../services/firebase_auth_service.dart';
import '../models/task_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _authService = FirebaseAuthService.instance;
  final _taskRepository = FirebaseTaskRepository.instance;
  DateTime _activeMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _loadTasks();
  }

  void _loadTasks() {
    if (_authService.isLoggedIn && _authService.currentUser?.id != null) {
      _tasksFuture = _taskRepository.getTasksByUserId(
        _authService.currentUser!.id!,
      );
    } else {
      _tasksFuture = Future.value([]);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + delta);
      _loadTasks();
    });
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
                if (!snapshot.hasData) {
                  return const Center(child: Text('Tidak ada data.'));
                }
                final tasks = snapshot.data!
                    .where(
                      (t) =>
                          t.startTime.month == _activeMonth.month &&
                          t.startTime.year == _activeMonth.year,
                    )
                    .toList();
                final total = tasks.length;
                final selesai = tasks.where((t) => t.isCompleted).length;
                final pending = total - selesai;

                if (total == 0) {
                  return const Center(
                    child: Text('Belum ada tugas di bulan ini.'),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: selesai.toDouble(),
                              title: 'Selesai\n$selesai',
                              radius: 70,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.red,
                              value: pending.toDouble(),
                              title: 'Pending\n$pending',
                              radius: 70,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Total Tugas: $total',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendBox(color: Colors.green, label: 'Selesai'),
                        const SizedBox(width: 16),
                        _LegendBox(color: Colors.red, label: 'Pending'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Persentase Selesai: ${total == 0 ? 0 : ((selesai / total) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendBox({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 6),
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
