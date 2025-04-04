import 'package:flutter/material.dart';
import '../database.dart';
import '../user_repository.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

void _addItem() async {
  if (_formKey.currentState!.validate()) {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
      );
      return;
    }

    final db = AppDatabase.instance;
    await db.addItem({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'users_id': userId,
      'category': 'Inne',
      'quantity': 1,
      'image': '',
      'is_auction': 0,
      'end_date': null,
    });
    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dodaj przedmiot")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Tytuł"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź tytuł";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Opis"),
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Cena"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return "Wprowadź poprawną cenę";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addItem,
                child: Text("Dodaj"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}