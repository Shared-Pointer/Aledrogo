import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database.dart';
import '../user_repository.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

typedef CategoryEntry = DropdownMenuEntry<CategoryLabel>;

// DropdownMenuEntry labels and values for the second dropdown menu.
enum CategoryLabel {
  odziez('Odzież'),
  elektronika('Elektronika'),
  obuwe('Obuwie'),
  toys('Zabawki'),
  collectioner_items('Kolekjonerskie'),
  appliances('AGD/RTV'),
  games('Konsole i Gry'),
  other('Inne');

  // 'Odzież','Elektronika','Obuwie','Zabawki','Kolekcjonerskie','AGD/RTV','Konsole i Gry','Inne'
  const CategoryLabel(this.label);
  final String label;

  static final List<CategoryEntry> entries = UnmodifiableListView<CategoryEntry>(
    values.map<CategoryEntry>(
      (CategoryLabel icon) => CategoryEntry(value: icon, label: icon.label),
    ),
  );
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  

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
      'category': _categoryController.text,
      'quantity': 1,
      'image': '',
      'is_auction': 0,
      'end_date': null,
    });
    // Navigator.pop(context);
    context.pop();
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
              DropdownMenu<CategoryLabel>(
                initialSelection: CategoryLabel.other,
                controller: _categoryController,
                requestFocusOnTap: true,
                label: const Text('Kategoria'),
                onSelected: (CategoryLabel? category) {},
                dropdownMenuEntries: CategoryLabel.entries,
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