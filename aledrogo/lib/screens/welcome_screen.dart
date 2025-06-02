import 'package:flutter/material.dart';
import '../user_repository.dart';

class WelcomeScreen extends StatelessWidget {
  final String email;

  WelcomeScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            return Center(child: Text("Wystąpił błąd: ${snapshot.error}"));
          } else {
            final userData = snapshot.data ?? {};

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Witaj, $email!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          InfoRow(icon: Icons.location_city, label: "Miasto", value: userData['city']),
                          InfoRow(icon: Icons.home, label: "Adres", value: userData['street']),
                          InfoRow(icon: Icons.house, label: "Numer domu", value: userData['house_number']),
                          InfoRow(icon: Icons.phone, label: "Telefon", value: userData['phone_number']),
                          InfoRow(icon: Icons.local_post_office, label: "Kod pocztowy", value: userData['postal_code']),
                          InfoRow(icon: Icons.account_balance_wallet, label: "Saldo", value: userData['saldo'] != null ? "${userData['saldo']} zł" : ""),
                        ],
                      ),
                    ),
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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;

  const InfoRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty ? value.toString() : "-",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
