import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.aero_stream.playback',
    androidNotificationChannelName: 'Aero Stream Playback',
    androidNotificationOngoing: true,
  );
  runApp(const ProviderScope(child: AeroStreamApp()));
}
