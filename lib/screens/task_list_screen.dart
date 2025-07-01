import 'package:flutter/material.dart';
import '../repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    // Ganti userId sesuai implementasi login Anda
    _tasksFuture = TaskRepository().getTasksByUserId(1);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/tambah-tugas',
              );
              if (result == true) _refresh();
            },
            tooltip: 'Tambah Tugas',
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada tugas.'));
          }
          final tasks = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = tasks[i];
                return ListTile(
                  leading: Icon(
                    t.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: t.isCompleted ? Colors.green : Colors.grey,
                  ),
                  title: Text(t.title),
                  subtitle: Text(
                    '${t.startTime.hour.toString().padLeft(2, '0')}:${t.startTime.minute.toString().padLeft(2, '0')} - '
                    '${t.endTime.hour.toString().padLeft(2, '0')}:${t.endTime.minute.toString().padLeft(2, '0')}'
                    ' | ${t.priority}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await TaskRepository().deleteTask(t.id!);
                      _refresh();
                    },
                  ),
                  onTap: () async {
                    if (!t.isCompleted) {
                      await TaskRepository().markTaskAsCompleted(t.id!);
                      _refresh();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
