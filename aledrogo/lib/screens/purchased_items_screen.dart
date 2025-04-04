import 'package:flutter/material.dart';
import '../database.dart';
import '../item.dart';
import '../user_repository.dart';

class PurchasedItemsScreen extends StatelessWidget {
  Future<List<Item>> fetchPurchasedItems() async {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      print("User ID is null");
      return [];
    }
    final db = AppDatabase.instance;
    final itemsData = await db.getPurchasedItems(userId); // Poprawiono obsługę Future
    print("Fetched purchased items for user $userId: $itemsData");
    return itemsData.map((data) => Item.fromMap(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kupione przedmioty")),
      body: FutureBuilder<List<Item>>(
        future: fetchPurchasedItems(),
        builder: (context, snapshot) {
          print("Snapshot state: ${snapshot.connectionState}, data: ${snapshot.data}, error: ${snapshot.error}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Brak kupionych przedmiotów"));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
                trailing: Text("${item.price} zł"),
              );
            },
          );
        },
      ),
    );
  }
}