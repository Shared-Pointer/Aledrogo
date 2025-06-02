import 'package:flutter/material.dart';
import '../user_repository.dart';
import '../database.dart';

class OptionsScreen extends StatefulWidget {
  final String email;

  OptionsScreen({required this.email});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _saldo = TextEditingController();

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await getUserData();
    setState(() {
      _userData = userData;
      _cityController.text = userData['city'] ?? '';
      _streetController.text = userData['street'] ?? '';
      _houseNumberController.text = userData['house_number'] ?? '';
      _phoneNumberController.text = userData['phone_number'] ?? '';
      _postalCodeController.text = userData['postal_code'] ?? '';
      _saldo.text = userData['saldo']?.toString() ?? '';
    });
  }

  Future<void> _saveUserData() async {
    final userId = _userData?['id'];
    if (userId == null) return;

    await AppDatabase.instance.addUserData(
      userId,
      _cityController.text,
      _streetController.text,
      _houseNumberController.text,
      _phoneNumberController.text,
      _postalCodeController.text,
      double.tryParse(_saldo.text) ?? 0.0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dane zostały zapisane!")),
    );
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Opcje"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(labelText: "Miasto"),
                    ),
                    TextFormField(
                      controller: _streetController,
                      decoration: InputDecoration(labelText: "Ulica"),
                    ),
                    TextFormField(
                      controller: _houseNumberController,
                      decoration: InputDecoration(labelText: "Numer domu"),
                    ),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(labelText: "Telefon"),
                    ),
                    TextFormField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(labelText: "Kod pocztowy"),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: Text("Zapisz dane"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}