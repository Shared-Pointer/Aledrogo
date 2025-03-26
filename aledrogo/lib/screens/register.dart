import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'user_repository.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // global key przechowuje stan formularza, i dzieki niemu walidujemy pola tekstowe
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  void _registerUser() async {
    // sprawdz dane z pol tekstowych
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      int id = await _userRepository.registerUser(name, email, password);
      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rejestracja udana!")),
        );
        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd rejestracji!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rejestracja")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nazwa użytkownika"),
                validator: (value) => value!.isEmpty ? "Podaj nazwę użytkownika" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Podaj email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Hasło"),
                obscureText: true,
                validator: (value) => value!.length < 6 ? "Hasło za krótkie" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text("Zarejestruj się"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
