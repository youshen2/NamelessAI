import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _thinkingChannelId = 'nameless_ai_thinking_channel';
  static const _thinkingChannelName = 'Thinking Notifications';
  static const _thinkingChannelDescription =
      'Persistent notification shown while generating a response.';
  static const _thinkingNotificationId = 2;

  static const _resultChannelId = 'nameless_ai_result_channel';
  static const _resultChannelName = 'Result Notifications';
  static const _resultChannelDescription =
      'Notifications shown when a response is complete or an error occurs.';
  static const _resultNotificationId = 1;

  Future<void> init() async {
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
            appName: 'Nameless AI Box',
            appUserModelId: 'Moye.NamelessAIBox',
            guid: 'f782787f-a589-4443-a713-9a0c3a5d3c67');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {},
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    const AndroidNotificationChannel thinkingChannel =
        AndroidNotificationChannel(
      _thinkingChannelId,
      _thinkingChannelName,
      description: _thinkingChannelDescription,
      importance: Importance.low,
      showBadge: false,
    );

    const AndroidNotificationChannel resultChannel = AndroidNotificationChannel(
      _resultChannelId,
      _resultChannelName,
      description: _resultChannelDescription,
      importance: Importance.defaultImportance,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(thinkingChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(resultChannel);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.requestNotificationsPermission() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final plugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await plugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  static bool isSupported() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  Future<void> showThinkingNotification(AppLocalizations localizations) async {
    if (!isSupported()) return;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _thinkingChannelId,
      _thinkingChannelName,
      channelDescription: _thinkingChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      maxProgress: 0,
      indeterminate: true,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.startForegroundService(
        _thinkingNotificationId,
        localizations.notificationTitleThinking,
        null,
        notificationDetails: androidPlatformChannelSpecifics,
        foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeDataSync,
        },
      );
    } else {
      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _flutterLocalNotificationsPlugin.show(
        _thinkingNotificationId,
        localizations.notificationTitleThinking,
        null,
        platformChannelSpecifics,
      );
    }
  }

  Future<void> showCompletionNotification(
      AppLocalizations localizations) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _resultChannelId,
      _resultChannelName,
      channelDescription: _resultChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      _resultNotificationId,
      localizations.notificationTitleComplete,
      localizations.notificationBodyComplete,
      platformChannelSpecifics,
    );
  }

  Future<void> showErrorNotification(AppLocalizations localizations) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _resultChannelId,
      _resultChannelName,
      channelDescription: _resultChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      _resultNotificationId,
      localizations.notificationTitleError,
      localizations.notificationBodyError,
      platformChannelSpecifics,
    );
  }

  Future<void> cancelThinkingNotification() async {
    if (!isSupported()) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.stopForegroundService();
    } else {
      await _flutterLocalNotificationsPlugin.cancel(_thinkingNotificationId);
    }
  }
}
