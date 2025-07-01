import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() =>
      _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  String _permissionStatus = 'Checking...';
  String _lastNotificationInfo = 'No notification sent yet';
  final _titleController = TextEditingController(text: 'Test Notification');
  final _bodyController = TextEditingController(
    text: 'This is a test notification',
  );
  int _delaySeconds = 5;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _permissionStatus = 'Permission status: $status';
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _permissionStatus = 'New status: $status';
    });
  }

  Future<void> _sendImmediateNotification() async {
    try {
      final now = DateTime.now();
      await NotificationService().showNotification(
        id: 10001,
        title: _titleController.text,
        body: '${_bodyController.text} (${now.toString()})',
        sound: true,
      );
      setState(() {
        _lastNotificationInfo =
            'Immediate notification sent at ${now.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Immediate notification sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _sendDelayedNotification() async {
    try {
      final now = DateTime.now();
      final scheduledTime = now.add(Duration(seconds: _delaySeconds));
      await NotificationService().scheduleNotification(
        id: 10002,
        title: 'Delayed: ${_titleController.text}',
        body:
            '${_bodyController.text} (scheduled for ${scheduledTime.toString()})',
        scheduledTime: scheduledTime,
        sound: true,
      );
      setState(() {
        _lastNotificationInfo =
            'Delayed notification scheduled for ${scheduledTime.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification scheduled in $_delaySeconds seconds'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Notifikasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Izin Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_permissionStatus),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _requestPermission,
                    icon: const Icon(Icons.app_settings_alt),
                    label: const Text('Minta Izin'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Buka Settings'),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Kirim Notifikasi Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Notifikasi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi Notifikasi',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Delay (detik): '),
                Expanded(
                  child: Slider(
                    value: _delaySeconds.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: _delaySeconds.toString(),
                    onChanged: (value) {
                      setState(() {
                        _delaySeconds = value.round();
                      });
                    },
                  ),
                ),
                Text('$_delaySeconds'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendImmediateNotification,
                    icon: const Icon(Icons.notifications),
                    label: const Text('Kirim Sekarang'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendDelayedNotification,
                    icon: const Icon(Icons.timer),
                    label: const Text('Kirim Terjadwal'),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Info Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_lastNotificationInfo),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips Debugging:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('1. Tutup aplikasi (keluar sepenuhnya)'),
                  Text('2. Kirim notifikasi terjadwal'),
                  Text('3. Tunggu hingga waktunya'),
                  Text('4. Jika tidak muncul, restart device'),
                  Text('5. Periksa izin di pengaturan aplikasi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
