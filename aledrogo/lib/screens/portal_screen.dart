import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../user_repository.dart';

class PortalScreen extends StatelessWidget {
  final String email;

  PortalScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portal"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: $email"),
                  SizedBox(height: 16),
                  Text("Tutaj jest ekran sprzedaży/kupna przedmiotów"),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/itemsList'),
                    child: Text("Lista przedmiotów"),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/sellList'),
                    child: Text("Lista przedmiotów na sprzedaż"),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/addItem'),
                    child: Text("Dodaj przedmiot"),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}