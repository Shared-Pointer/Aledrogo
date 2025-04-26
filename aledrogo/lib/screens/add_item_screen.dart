import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;

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
        'category': _selectedCategory ?? CategoryLabel.other.label,
        'quantity': 1,
        'image': _imageFile?.path ?? '',
        'is_auction': 0,
        'end_date': null,
      });
      // Navigator.pop(context);
      context.pop();
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd podczas wybierania obrazu")),
      );
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
              Semantics(
                label: 'image_picker',
                child: FloatingActionButton(
                  onPressed: () {
                    _onImageButtonPressed(ImageSource.gallery);
                  },
                  heroTag: 'image0',
                  tooltip: 'Pick Image from gallery',
                  child: const Icon(Icons.photo),
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Image.file(
                    File(_imageFile!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
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
                onSelected: (CategoryLabel? category) {
                  setState(() {
                    _selectedCategory = category?.label;
                  });
                },
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
