import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database.dart';
import '../item.dart';
import '../user_repository.dart';
import 'purchased_items_screen.dart'; 

class ItemListScreen extends StatelessWidget {
  Future<List<Item>> fetchItems() async {
    final db = AppDatabase.instance;
    final itemsData = await db.getAvailableItems();
    return itemsData.map((data) => Item.fromMap(data)).toList();
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

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => PurchasedItemsScreen()),
    // );
    context.push('/purchasedItems');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista przedmiotów"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart), 
            onPressed: () { 
              context.push('/purchasedItems'); 
            }, 
          ), 
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Brak przedmiotów do wyświetlenia"));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text("${item.price} PLN"),
                  trailing: ElevatedButton(
                    onPressed: () => _buyItem(context, item),
                    child: Text("Kup"),
                  ),
                  onTap: () {
                    // Opcjonalnie: przejście do szczegółów przedmiotu
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
