import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'sign_in.dart';
import 'config.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.load();

  FirebaseOptions firebaseOptions;

  if (kIsWeb) {
    firebaseOptions = FirebaseOptions(
      apiKey: Config.firebaseApiKeyWeb,
      projectId: Config.firebaseProjectId,
      messagingSenderId: Config.firebaseSenderId,
      appId: Config.firebaseAppIdWeb,
    );
  } else {
    firebaseOptions = FirebaseOptions(
      apiKey: Platform.isIOS
          ? Config.firebaseApiKeyIos
          : Config.firebaseApiKeyAndroid,
      projectId: Config.firebaseProjectId,
      messagingSenderId: Config.firebaseSenderId,
      appId: Platform.isIOS
          ? Config.firebaseAppIdIos
          : Config.firebaseAppIdAndroid,
    );
  }

  Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AREA',
      home: const LoginPage(),
      routes: {
        '/widget': (context) => const HomePage(),
        '/signin': (context) => const LoginPage(),
      },
    );
  }
}
