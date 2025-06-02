import 'dart:io';
import 'package:aledrogo/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database.dart';
import '../item.dart';

class ItemScreen extends StatelessWidget {
  final int itemId;

  ItemScreen({required this.itemId});

  Future<Item> fetchItemDetail() async {
  final db = AppDatabase.instance;
  final itemDataList = await db.getItemDetails(itemId);

  if (itemDataList.isEmpty) {
    throw Exception("Item not found");
  }

  final itemData = itemDataList.first;
  return Item.fromMap(itemData);
}

  void _buyItem(BuildContext context, Item item) async {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
      );
      return;
    }

    final db = AppDatabase.instance;
    await db.addTransaction(
      userId, 
      item.usersId, 
      item.id,
      item.price,
      DateTime.now().toIso8601String(),
    );

    if (item.quantity > 1) {
      await db.updateItem(item.id, {'quantity': item.quantity - 1});
    } else {
      // Zamiast usuwania, ustawiamy ilość na 0.
      await db.updateItem(item.id, {'quantity': 0});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Przedmiot został kupiony!")),
    );

    context.pushReplacement('/purchasedItems');
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Szczegóły przedmiotu')),
    body: FutureBuilder<Item>(
      future: fetchItemDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Błąd: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final item = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image.isNotEmpty
                      ? Image.file(
                          File(item.image),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey[600]),
                        ),
                ),

                SizedBox(height: 24),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _infoRow(Icons.description, "Opis", item.description),
                        Divider(),
                        _infoRow(Icons.category, "Kategoria", item.category),
                        Divider(),
                        _infoRow(Icons.monetization_on, "Cena", "${item.price.toStringAsFixed(2)} zł"),
                        if (item.quantity > 0) ...[
                          Divider(),
                          _infoRow(Icons.inventory_2, "Dostępna ilość", "${item.quantity} szt."),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    label: Text(
                      "Kup teraz",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: item.quantity > 0 ? () => _buyItem(context, item) : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: item.quantity > 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      foregroundColor: Colors.white, // <-- kolor tekstu/ikony
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text("Brak danych dla przedmiotu o ID: $itemId"));
        }
      },
    ),
  );
}

Widget _infoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.blueAccent),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(value.isNotEmpty ? value : "-", style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    ],
  );
}
}
