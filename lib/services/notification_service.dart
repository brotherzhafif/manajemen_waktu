import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _tzInitialized = false;

  // Channel info
  static const String channelId = 'task_notification_channel';
  static const String channelName = 'Task Notifications';
  static const String channelDesc = 'Notifikasi tugas dan pengingat';

  Future<void> init() async {
    debugPrint('🔔 Initializing NotificationService...');
    if (!_tzInitialized) {
      tzdata.initializeTimeZones();
      _tzInitialized = true;
      debugPrint('🔔 Timezone initialized');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    debugPrint('🔔 Android settings initialized');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    debugPrint('🔔 iOS settings initialized');

    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification tapped: ${response.payload}');
      },
    );
    debugPrint('🔔 Plugin initialized');

    await _requestPermissions();
    await _createNotificationChannel();
    debugPrint('🔔 NotificationService initialization complete!');

    // Tes izin notifikasi
    _checkNotificationPermissions();
  }

  Future<void> _requestPermissions() async {
    debugPrint('🔔 Requesting notification permissions...');
    // Permissions are only required on iOS/macOS. No need to request on Android.
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    debugPrint('🔔 Permissions requested');
  }

  // Fungsi untuk mengecek izin notifikasi
  Future<void> _checkNotificationPermissions() async {
    debugPrint('🔔 Checking notification permissions...');
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final bool? areEnabled = await androidPlugin.areNotificationsEnabled();
      debugPrint('🔔 Notifications enabled on Android: $areEnabled');
    } else {
      debugPrint('🔔 Android plugin not available for permission check');
    }
  }

  Future<void> _createNotificationChannel() async {
    debugPrint('🔔 Creating notification channel...');
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.high,
      enableVibration: true,
      showBadge: true,
      playSound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    debugPrint('🔔 Notification channel created: ${channel.id}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool sound = true,
    bool repeatDaily = false,
    String? payload,
  }) async {
    debugPrint(
      '🔔 Scheduling notification #$id for: ${scheduledTime.toString()}',
    );
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: sound,
            enableVibration: true,
            styleInformation: const BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: sound,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
        payload: payload,
      );
      debugPrint('🔔 Notification #$id scheduled successfully');
    } catch (e) {
      debugPrint('❌ Error scheduling notification #$id: $e');
      rethrow;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool sound = true,
    String? payload,
  }) async {
    debugPrint('🔔 Showing immediate notification #$id');
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: sound,
            styleInformation: const BigTextStyleInformation(''),
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: sound,
          ),
        ),
        payload: payload,
      );
      debugPrint('🔔 Immediate notification #$id shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing notification #$id: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
