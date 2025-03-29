import 'package:flutter/material.dart';
import '../user_repository.dart';

class SellListScreen extends StatelessWidget {
  final String email;

  SellListScreen({required this.email});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of items to sell"),
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
                  Text("email: $email"),
                  Text("Tutaj jest lista produktow ktore uzytkownik wystawia"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}