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
                  Text("email: $email"),
                  Text("Tutaj jest ekran sprzedazy/kupna przedmiotow"),
                  ElevatedButton(
                    onPressed: () => context.push('/itemsList'),
                    child: Text("List of products"),
                  ), 
                  ElevatedButton(
                    onPressed: () => context.push('/sellList'),
                    child: Text("List of products to sell"),
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
