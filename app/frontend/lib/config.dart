import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static late final String apiBaseUrl;
  static late final String webClientId;
  static late final String iosClientId;
  static late final String androidClientId;
  static late final String firebaseApiKeyWeb;
  static late final String firebaseApiKeyAndroid;
  static late final String firebaseApiKeyIos;
  static late final String firebaseProjectId;
  static late final String firebaseSenderId;
  static late final String firebaseAppIdWeb;
  static late final String firebaseAppIdAndroid;
  static late final String firebaseAppIdIos;

  static bool _isLoaded = false;

  static Future<void> load() async {
    if (!_isLoaded) {
      await dotenv.load();
      apiBaseUrl = dotenv.env['API_BASE_URL']!;
      webClientId = dotenv.env['WEB_CLIENT_ID']!;
      iosClientId = dotenv.env['IOS_CLIENT_ID']!;
      androidClientId = dotenv.env['ANDROID_CLIENT_ID']!;
      firebaseApiKeyWeb = dotenv.env['FIREBASE_API_KEY_WEB']!;
      firebaseApiKeyAndroid = dotenv.env['FIREBASE_API_KEY_ANDROID']!;
      firebaseApiKeyIos = dotenv.env['FIREBASE_API_KEY_IOS'] ?? '';
      firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID']!;
      firebaseSenderId = dotenv.env['FIREBASE_SENDER_ID']!;
      firebaseAppIdWeb = dotenv.env['FIREBASE_APP_ID_WEB']!;
      firebaseAppIdAndroid = dotenv.env['FIREBASE_APP_ID_ANDROID']!;
      firebaseAppIdIos = dotenv.env['FIREBASE_APP_ID_IOS'] ?? '';

      _isLoaded = true;
    }
  }
}
