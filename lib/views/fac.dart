import 'package:flutter/material.dart';

class Fac extends StatelessWidget {
  const Fac({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

