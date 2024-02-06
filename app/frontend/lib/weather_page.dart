import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage.dart';
import 'config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WeatherPage extends StatefulWidget {
  final Function onConfigured;

  const WeatherPage({super.key, required this.onConfigured});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  Future<void> _sendWeatherRequest() async {
    String? token = await Storage.getToken();

    if (token != null) {
      var url = Uri.parse('${Config.apiBaseUrl}/area/meteo');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': _emailController.text,
          'city': _cityController.text,
          'degree': _degreeController.text,
          'interval': _intervalController.text,
          'value': _valueController.text,
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
                      'Weather Widget', // Add the text you want to display
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
                      hintText: 'Enter your email adress',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter the city',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _degreeController,
                    decoration: const InputDecoration(
                      labelText: 'Degree',
                      hintText: 'Enter the degree to check for',),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _intervalController,
                    decoration: const InputDecoration(
                      labelText: 'Interval',
                      hintText: 'Enter the interval in seconds',),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'Enter 0 or 1',),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _sendWeatherRequest,
                    child: const Text('Send Weather Request'),
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
