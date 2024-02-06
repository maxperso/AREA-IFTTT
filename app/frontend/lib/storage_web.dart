import 'dart:html' as html;
class Storage {
  static Future<void> saveToken(String token) async {
    html.window.localStorage['jwt_token'] = token;
  }

  static String? getToken() {
    return html.window.localStorage['jwt_token'];
  }
}
