import 'package:flutter/material.dart';

class PortalScreen extends StatelessWidget {
  final String email;

  PortalScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: $email"), // Wyświetlenie przekazanego emaila
            // Możesz dodać więcej danych tutaj
          ],
        ),
      ),
    );
  }
}
