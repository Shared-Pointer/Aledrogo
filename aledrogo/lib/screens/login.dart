import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../user_repository.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      bool isLoggedIn = await _userRepository.loginUser(email, password);

      if (isLoggedIn) {
        context.go('/welcome');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błędny email lub hasło!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logowanie")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => value!.isEmpty ? "Podaj email" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Hasło"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "Podaj hasło" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginUser,
                child: Text("Zaloguj się"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}