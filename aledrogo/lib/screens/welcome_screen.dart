import 'package:flutter/material.dart';
import '../user_repository.dart';

class WelcomeScreen extends StatelessWidget {
  final String email;

  WelcomeScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello!"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>( //jak coś to future builder jest użyty w celu uzyskania asynchronicznych operacji w tym przypadku pobrania danych usera
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final userData = snapshot.data ?? {};
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // po prostu żeby sobie elegancko wyświetlić dane żeby zobaczyc czy git jest
                  Text("email: $email"),
                  Text("miasto: ${userData['city'] ?? ''}"),
                  Text("adres: ${userData['street'] ?? ''}"),
                  Text("numer dmu: ${userData['house_number'] ?? ''}"),
                  Text("nr telefonu: ${userData['phone_number'] ?? ''}"),
                  Text("kod pocztowy: ${userData['postal_code'] ?? ''}"),
                  Text("siano na koncie: ${userData['saldo'] ?? ''}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}