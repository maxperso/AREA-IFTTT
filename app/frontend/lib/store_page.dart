import 'package:flutter/material.dart';

class ActiveWidgetPage extends StatelessWidget {
  const ActiveWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text("You currently have no active widgets"),
        ),
      ),
    );
  }
}
