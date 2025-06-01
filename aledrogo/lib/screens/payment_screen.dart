import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double amount;
  final Function(String) onPaymentSuccess;

  PaymentScreen({required this.amount, required this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wybierz metodę płatności")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Do zapłaty: ${amount.toStringAsFixed(2)} PLN", style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                //dummy BLIK
                onPaymentSuccess("BLIK");
                Navigator.pop(context);
              },
              child: Text("Zapłać BLIK"),
            ),
            ElevatedButton(
              onPressed: () {
                //dummy karta płatnicza
                onPaymentSuccess("Karta");
                Navigator.pop(context);
              },
              child: Text("Zapłać kartą płatniczą"),
            ),
          ],
        ),
      ),
    );
  }
}