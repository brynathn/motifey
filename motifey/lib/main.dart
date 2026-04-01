import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'router.dart';
import 'services/audio_handler.dart';
import 'controller/audio_controller.dart'; 

late final MyAudioHandler handler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 INIT");

  handler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.motifey.audio',
      androidNotificationChannelName: 'Motifey Playback',
      androidNotificationOngoing: true,
    ),
  );

  print("✅ INIT SUCCESS");

  AudioController.instance.init(handler);

  // 🔥 REQUEST NOTIFICATION (ANDROID 13+)
  await Permission.notification.request();

  runApp(const Motifey());
}

class Motifey extends StatelessWidget {
  const Motifey({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Motifey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      routerConfig: router,
    );
  }
}