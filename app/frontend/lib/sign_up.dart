import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'dart:io';
import 'storage.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _userDisplayName;
  String? _userEmail;
  String? _userPhotoUrl;


  SignUpPage({super.key});

  Future<void> _register(BuildContext context) async {
    var url = '${Config.apiBaseUrl}/auth/signup';

    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'email': _email.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      await _showSuccessDialog(context);
    } else {
      await _showFailureDialog(context);
    }
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    // Popup de succès
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Inscription Réussie"),
        content: const Text("Vous êtes maintenant inscrit."),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(ctx).pop(); // Ferme la popup
              _navigateToSignIn(context); // Redirige vers la page de connexion
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showFailureDialog(BuildContext context) async {
    // Popup d'échec
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Échec de l'Inscription"),
        content: const Text("L'inscription a échoué. Veuillez réessayer."),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(ctx).pop(), // Ferme la popup
          ),
        ],
      ),
    );
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0; // Fully transparent
          const end = 1.0; // Fully opaque
          var tween = Tween<double>(begin: begin, end: end);
          var opacityAnimation = animation.drive(tween);
          return FadeTransition(
            opacity: opacityAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _signInWithGoogle(BuildContext context) async {
    try {
      String clientId;

      if (kIsWeb) {
        clientId = Config.webClientId;
      } else if (Platform.isIOS) {
        clientId = Config.iosClientId;
      } else {
        clientId = Config.androidClientId;
      }

      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(clientId: clientId).signIn();

      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        var url = '${Config.apiBaseUrl}/auth/google';
        var response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': user.displayName,
            'email': user.email,
            'token': googleAuth.accessToken,
          }),
        );

        if (response.statusCode == 200) {
          var body = json.decode(response.body);
          var token =
              body.containsKey('tokenn') ? body['tokenn'] : body['new_token'];
          var areas = body['areas'];
          _userDisplayName = user.displayName;
          _userEmail = user.email;
          _userPhotoUrl = user.photoURL;

          await Storage.saveToken(token);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userArea', json.encode(areas));

          _navigateToHome(context);
        } else {
          debugPrint('Échec de la connexion Google avec l\'API');
        }
      } else {
        debugPrint('La connexion Google a échoué.');
      }
    } catch (error) {
      debugPrint('Erreur lors de la connexion Google: $error');
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          userDisplayName: _userDisplayName,
          userEmail: _userEmail,
          userPhotoUrl: _userPhotoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          if (kIsWeb) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(255, 196, 69, 60), Color.fromARGB(255, 120, 60, 60)], // You can adjust the colors as needed
                ),
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: const EdgeInsets.all(40.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 233, 233, 233), Color.fromARGB(255, 186, 186, 186)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0), // Add border radius for rounded corners
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/WebTrLogo.png',
                              height: 40.0,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 32.0),
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                        ),
                        const SizedBox(height: 14.0),
                        TextField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 14.0),
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 14.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if (_email.text.isNotEmpty &&
                                    _usernameController.text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty) {
                                  _register(context);
                                }
                              },
                              child: const Text('Sign Up'),
                            ),
                            InkWell(
                              onTap: () {
                                _signInWithGoogle(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png', // Replace with the path to your Google logo
                                      height: 20.0,
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Text('Sign Up with Google'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {
                            _navigateToSignIn(context); // Pass the context here
                          },
                          child: const Text('Already have an account? Sign In'),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/WebTrLogo.png',
                          height: 40.0,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 32.0),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 14.0),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 14.0),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_email.text.isNotEmpty &&
                                _usernameController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              _register(context);
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                        InkWell(
                          onTap: () {
                            _signInWithGoogle(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png', // Replace with the path to your Google logo
                                  height: 20.0,
                                ),
                                const SizedBox(width: 8.0),
                                const Text('Sign Up with Google'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        _navigateToSignIn(context); // Pass the context here
                      },
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
