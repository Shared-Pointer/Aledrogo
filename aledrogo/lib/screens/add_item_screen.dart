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
  collectioner_items('Kolekcjonerskie'),
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
    appBar: AppBar(
      title: Text("Dodaj przedmiot"),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Tytuł",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Wprowadź tytuł";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Opis",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.image, color: Theme.of(context).primaryColor),
                        SizedBox(width: 10),
                        Text("Zdjęcie", style: Theme.of(context).textTheme.titleMedium),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _onImageButtonPressed(ImageSource.gallery),
                          icon: Icon(Icons.photo_library),
                          label: Text("Wybierz"),
                        ),
                      ],
                    ),
                    if (_imageFile != null) ...[
                      SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_imageFile!.path),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Cena",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return "Wprowadź poprawną cenę";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownMenu<CategoryLabel>(
                      initialSelection: CategoryLabel.other,
                      dropdownMenuEntries: CategoryLabel.entries,
                      onSelected: (CategoryLabel? category) {
                        setState(() {
                          _selectedCategory = category?.label;
                        });
                      },
                      label: Text("Kategoria"),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(),
                        prefixIconColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Dodaj przedmiot", style: TextStyle(fontSize: 16)),
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
