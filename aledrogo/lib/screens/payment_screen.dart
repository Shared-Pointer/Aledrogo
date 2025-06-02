import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final double amount;
  final Function(String) onPaymentSuccess;

  PaymentScreen({required this.amount, required this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text("Płatność"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.attach_money, size: 80, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              "Do zapłaty:",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(
              "${amount.toStringAsFixed(2)} PLN",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            SizedBox(height: 40),
            _buildPaymentButton(
              context,
              icon: Icons.qr_code_2,
              label: "Zapłać BLIK",
              method: "BLIK",
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            _buildPaymentButton(
              context,
              icon: Icons.credit_card,
              label: "Zapłać kartą płatniczą",
              method: "Karta",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(BuildContext context,
      {required IconData icon, required String label, required String method, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          onPaymentSuccess(method);
          Navigator.pop(context);
        },
      ),
    );
  }
}
