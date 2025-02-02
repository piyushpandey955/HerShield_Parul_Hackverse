
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PanicService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  String? _filePath;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  PanicService() {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initRecorder();
    _initNotifications();
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification);
  }

  Future<void> _showNotification(String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'recording_channel',
      'Recording Notifications',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation('Click to listen to your recording.'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      'Recording Complete',
      'File saved at: $filePath',
      platformChannelSpecifics,
      payload: filePath, // Attach file path as payload
    );
  }

  // Handle notification click
  Future<void> _onSelectNotification(NotificationResponse notificationResponse) async {
    String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification clicked. Playing audio from: $payload');
      await playRecording(payload);
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    Directory tempDir = await getApplicationDocumentsDirectory();
    _filePath = '${tempDir.path}/panic_audio${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(toFile: _filePath, codec: Codec.aacMP4);
    _isRecording = true;
    print("Recording started...");

    // Automatically stop recording after 10 seconds
    Future.delayed(const Duration(seconds: 10), () async {
      if (_isRecording) {
        await stopRecording();
        print("Recording automatically stopped after 10 seconds.");
      }
    });
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    await _recorder!.stopRecorder();
    _isRecording = false;
    print("Recording stopped. File saved at: $_filePath");

    if (_filePath != null) {
      _showNotification(_filePath!);
    }
  }

  String? getRecordedFilePath() {
    return _filePath;
  }

  // Function to play the recorded audio
  Future<void> playRecording(String filePath) async {
    try {
      // Initialize the player if not already open
      if (!_player!.isPlaying) {
        await _player!.openPlayer();
      }

      // Start playing the audio
      await _player!.startPlayer(fromURI: filePath, codec: Codec.aacMP4);
      print('Playing recording...');
    } catch (e) {
      print('Error playing recording: $e');
    }
  }
}



