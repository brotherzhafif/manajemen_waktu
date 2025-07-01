import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

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
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) return;
    setState(() => _isLoading = true);
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
    await TaskRepository().createTask(task);
    setState(() => _isLoading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama Tugas'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDateTime == null
                      ? 'Pilih Waktu Tugas'
                      : '${_selectedDateTime!.day.toString().padLeft(2, '0')}-'
                            '${_selectedDateTime!.month.toString().padLeft(2, '0')}-'
                            '${_selectedDateTime!.year} '
                            '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:'
                            '${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'High', child: Text('Tinggi')),
                  DropdownMenuItem(value: 'Medium', child: Text('Sedang')),
                  DropdownMenuItem(value: 'Low', child: Text('Rendah')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
                decoration: const InputDecoration(labelText: 'Prioritas'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
