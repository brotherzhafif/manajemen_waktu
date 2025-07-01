import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDateTime;
  String _priority = 'Medium';
  bool _isLoading = false;
  String? _errorMsg;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      setState(() {
        _errorMsg = _selectedDateTime == null
            ? "Waktu tugas wajib diisi"
            : null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // Ganti userId sesuai login
      final int userId = 1;
      final task = Task(
        title: _titleController.text,
        description: _descController.text,
        startTime: _selectedDateTime!,
        endTime: _selectedDateTime!.add(const Duration(hours: 1)),
        priority: _priority,
        userId: userId,
        isCompleted: false,
      );
      final taskId = await TaskRepository().createTask(task);

      // Pastikan notifikasi muncul segera (yang akan muncul di system tray)
      await NotificationService().showNotification(
        id: taskId,
        title: 'Tugas Baru Ditambahkan',
        body:
            '${task.title} - ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
        sound: true, // Aktifkan suara
        payload: 'task_$taskId', // payload untuk navigasi saat notif diklik
      );

      // Jadwalkan notifikasi pengingat 1 jam sebelum waktu mulai tugas
      if (_selectedDateTime!.isAfter(
        DateTime.now().add(const Duration(hours: 1)),
      )) {
        final reminderTime = _selectedDateTime!.subtract(
          const Duration(hours: 1),
        );
        await NotificationService().scheduleNotification(
          id: taskId * 100 + 1, // pastikan ID unik
          title: 'Pengingat: ${task.title}',
          body: 'Tugas dimulai dalam 1 jam lagi. Klik untuk melihat detail.',
          scheduledTime: reminderTime,
          sound: true,
          payload: 'task_$taskId',
        );
      }

      // Jadwalkan notifikasi pada waktu mulai tugas
      await NotificationService().scheduleNotification(
        id: taskId * 100 + 2,
        title: 'Tugas Dimulai: ${task.title}',
        body: 'Waktu untuk memulai tugas ${task.title}',
        scheduledTime: _selectedDateTime!,
        sound: true,
        payload: 'task_$taskId',
      );

      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tugas berhasil ditambahkan! Notifikasi akan muncul.',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = "Gagal menyimpan tugas: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.add_task, size: 60, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Tambah Tugas Baru',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMsg != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Tugas',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.blue[50],
                    title: Text(
                      _selectedDateTime == null
                          ? 'Pilih Waktu Tugas'
                          : '${_selectedDateTime!.day.toString().padLeft(2, '0')}-'
                                '${_selectedDateTime!.month.toString().padLeft(2, '0')}-'
                                '${_selectedDateTime!.year} '
                                '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:'
                                '${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedDateTime == null
                            ? Colors.grey
                            : Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    onTap: _pickDateTime,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    items: const [
                      DropdownMenuItem(value: 'High', child: Text('Tinggi')),
                      DropdownMenuItem(value: 'Medium', child: Text('Sedang')),
                      DropdownMenuItem(value: 'Low', child: Text('Rendah')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
                    decoration: const InputDecoration(
                      labelText: 'Prioritas',
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTask,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
