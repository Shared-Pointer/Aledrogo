import 'package:flutter/material.dart';
import '../database.dart';
import '../user_repository.dart';

class CreateAuctionScreen extends StatefulWidget {
  @override
  _CreateAuctionScreenState createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startingPriceController = TextEditingController();
  int? _selectedItemId;
  DateTime? _endDate;

  Future<List<Map<String, dynamic>>> fetchAvailableItems() async {
    final db = AppDatabase.instance;
    return await db.getAvailableItems();
  }

  void _createAuction() async {
    if (_formKey.currentState!.validate() && _endDate != null && _selectedItemId != null) {
      final userId = await UserRepository().getUserId(); // Pobierz ID zalogowanego użytkownika
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
        );
        return;
      }

      final db = AppDatabase.instance;

      // Dodaj aukcję z kopiowaniem danych z tabeli items
      await db.addAuction({
        'item_id': _selectedItemId,
        'buyer_id': userId, // Ustaw buyer_id jako ID osoby wystawiającej
        'price': double.parse(_startingPriceController.text),
        'date': _endDate!.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Licytacja została stworzona")),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uzupełnij wszystkie wymagane pola")),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAvailableItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Brak dostępnych przedmiotów do wystawienia na aukcję"));
                  } else {
                    final items = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _selectedItemId,
                      items: items.map((item) {
                        return DropdownMenuItem<int>(
                          value: item['id'],
                          child: Text(item['title']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedItemId = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Wybierz przedmiot"),
                      validator: (value) => value == null ? "Wybierz przedmiot" : null,
                    );
                  }
                },
              ),
              TextFormField(
                controller: _startingPriceController,
                decoration: InputDecoration(labelText: 'Cena początkowa'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Pole wymagane' : null,
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
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createAuction,
                child: Text('Stwórz licytację'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}