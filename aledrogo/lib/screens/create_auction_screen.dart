import 'package:flutter/material.dart';
import '../database.dart';
import '../user_repository.dart';
import 'package:intl/intl.dart';

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
      final userId = await UserRepository().getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
        );
        return;
      }

      final db = AppDatabase.instance;

      await db.addAuction({
        'item_id': _selectedItemId,
        'buyer_id': userId,
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

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Stwórz licytację'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAvailableItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Brak dostępnych przedmiotów do wystawienia na aukcję",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  } else {
                    final items = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      value: _selectedItemId,
                      decoration: InputDecoration(
                        labelText: "Wybierz przedmiot",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
                      validator: (value) => value == null ? "Wybierz przedmiot" : null,
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _startingPriceController,
                decoration: InputDecoration(
                  labelText: 'Cena początkowa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.attach_money, color: Colors.deepPurple),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Pole wymagane';
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Podaj poprawną cenę';
                  return null;
                },
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _endDate = selectedDate;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data zakończenia',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _endDate == null ? 'Wybierz datę' : null,
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  ),
                  child: Text(
                    _endDate == null ? 'Wybierz datę zakończenia' : _formatDate(_endDate!),
                    style: TextStyle(
                      fontSize: 16,
                      color: _endDate == null ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createAuction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text('Stwórz licytację'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
