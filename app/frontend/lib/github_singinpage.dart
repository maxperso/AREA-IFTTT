import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage.dart';

class GitHubSignInWidget extends StatefulWidget {
  final Function(String) onConfigured;

  const GitHubSignInWidget({Key? key, required this.onConfigured})
      : super(key: key);

  @override
  _GitHubSignInWidgetState createState() => _GitHubSignInWidgetState();
}

class _GitHubSignInWidgetState extends State<GitHubSignInWidget> {
  final TextEditingController _repoUrlController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  String _status = 'Not signed in';

  Future<void> signInWithGitHub() async {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'];
    final redirectUri = dotenv.env['GITHUB_REDIRECT_URI'] ??
        'http://localhost:8080/auth/github';
    final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': 'repo',
    });

    try {
      if (await canLaunchUrl(authUrl)) {
        launchUrl(authUrl);
      } else {
        setState(() {
          _status = 'Failed to open GitHub auth URL';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error during GitHub auth: $e';
      });
    }
  }

  Future<void> sendDataToServer(String accessToken) async {
    String? token = await Storage.getToken();
    final response = await http.post(
      Uri.parse('http://localhost:8080/auth/githubb'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'repoUrl': _repoUrlController.text,
        'interval': _intervalController.text,
        'accessToken': accessToken,
        'mail': _mailController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _status = 'Data sent successfully';
      });
    } else {
      setState(() {
        _status = 'Failed to send data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repo Monitor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _repoUrlController,
              decoration: InputDecoration(labelText: 'Repository URL'),
            ),
            TextField(
              controller: _intervalController,
              decoration: InputDecoration(labelText: 'Interval in seconds'),
            ),
            TextField(
              controller: _mailController,
              decoration: InputDecoration(labelText: 'mail'),
            ),
            ElevatedButton(
              onPressed: () {
                signInWithGitHub();
                String accessToken = "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";
                sendDataToServer(accessToken);
              },
              child: const Text('Sign in and Send Data'),
            ),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
