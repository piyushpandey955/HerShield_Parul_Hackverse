import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationService {
  //handling foregorund notif in flutter app
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _localNotificationsPlugin.initialize(initializationSettings);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message);
      }
    });
  }
  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id', // Match with channel ID in FCM console
      'channel_name',
      importance: Importance.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }

//handle received notif to navigate to victims location
  static void initializeNotifClickingOnscreenWhenReceived() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('latitude') &&
          message.data.containsKey('longitude')) {
        final latitude = message.data['latitude'];
        final longitude = message.data['longitude'];

        final googleMapsUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        _launchUrl(Uri.parse(googleMapsUrl));
      }
    });
  }

  static Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}