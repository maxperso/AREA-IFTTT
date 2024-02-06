import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage.dart';
import 'config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BoursePage extends StatefulWidget {
  final Function onConfigured;

  const BoursePage({super.key, required this.onConfigured});

  @override
  _BoursePageState createState() => _BoursePageState();
}

class _BoursePageState extends State<BoursePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();

  Future<void> _sendBourseRequest() async {
    String? token = await Storage.getToken();
    if (token != null) {
      var url = Uri.parse('${Config.apiBaseUrl}/area/bourse');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': _emailController.text,
          'symbol': _symbolController.text,
          'interval': _intervalController.text,
        }),
      );

      if (response.statusCode == 200) {
        widget.onConfigured();
        Navigator.pop(context);
        debugPrint('Réponse du serveur: ${response.body}');
      } else {
        debugPrint('Erreur de requête: ${response.statusCode}');
      }
    } else {
      debugPrint("Token JWT non trouvé");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/WebTrLogo.png',
                height: 30,
              ),
              const SizedBox(width: 60,),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 196, 69, 60), Color.fromARGB(255, 120, 60, 60)], // You can adjust the colors as needed
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40.0),
            width: kIsWeb ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 233, 233, 233),
                  Color.fromARGB(255, 186, 186, 186)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                  20.0), // Add border radius for rounded corners
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Stock Market Widget', // Add the text you want to display
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size as needed
                        fontWeight:
                            FontWeight.bold, // Adjust the font weight as needed
                        color: Color.fromARGB(255, 69, 69, 69), // Adjust the text color as needed
                      ),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Symbol',
                      hintText: 'Enter the symbol of the stock',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Interval',
                      hintText: 'Enter the interval in seconds',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _sendBourseRequest,
                    child: const Text('Subscribe'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
