import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../database.dart';
import '../user_repository.dart';

class CreateAuctionScreen extends StatefulWidget {
  @override
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;
  DateTime? _endDate;

  void _createAuction() async {
    if (_formKey.currentState!.validate() && _endDate != null) {
      final userId = await UserRepository().getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
        );
        return;
      }

      final db = AppDatabase.instance;
      await db.addAuction({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.parse(_startingPriceController.text),
        'category': _selectedCategory ?? 'Inne',
        'image': _imageFile?.path ?? '',
        'end_date': _endDate!.toIso8601String(),
        'seller_id': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Licytacja została stworzona")),
      );
      Navigator.of(context).pop();
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
      appBar: AppBar(title: Text('Stwórz licytację')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                  controller: _startingPriceController,
                  decoration: InputDecoration(labelText: 'Cena początkowa'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Pole wymagane' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: [
                    'Odzież',
                    'Elektronika',
                    'Obuwie',
                    'Zabawki',
                    'Kolekcjonerskie',
                    'AGD/RTV',
                    'Konsole i Gry',
                    'Inne'
                  ].map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Kategoria"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _endDate = selectedDate;
                      });
                    }
                  },
                  child: Text(_endDate == null
                      ? 'Wybierz datę zakończenia'
                      : 'Data zakończenia: ${_endDate!.toLocal()}'),
                ),
                ElevatedButton(
                  onPressed: _createAuction,
                  child: Text('Stwórz licytację'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}