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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tytuł: ${item.title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  SizedBox(height: 16),
                    item.image.isNotEmpty
                        ? Image.file(
                          File(item.image),
                          fit: BoxFit.cover,
                        )
                        : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(child: Text('Brak obrazu')),
                          ),
                  Text('Opis: ${item.description}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Cena: ${item.price} zł', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Kategoria: ${item.category}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _buyItem(context, item),
                    child: Text("Kup"),
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
}
