import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database.dart';
import '../item.dart';
import '../user_repository.dart';
import 'payment_screen.dart';

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  List<Item> allItems = [];
  List<Item> filteredItems = [];
  String searchQuery = '';
  String selectedCategory = 'Wszystkie';
  String selectedSort = 'Brak sortowania';

  final List<String> categories = [
    'Wszystkie',
    'Elektronika',
    'Odzież',
    'Obuwie',
    'Zabawki',
    'Kolekcjonerskie',
    'AGD/RTV',
    'Konsole i Gry',
    'Inne'
  ];

  final List<String> sortOptions = [
    'Brak sortowania',
    'Cena rosnąco',
    'Cena malejąco',
    'Nazwa A-Z',
    'Nazwa Z-A',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final db = AppDatabase.instance;
    final itemsData = await db.getAvailableItems();
    final items = itemsData.map((data) => Item.fromMap(data)).toList();

    setState(() {
      allItems = items;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Item> tempItems = allItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'Wszystkie' || item.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    switch (selectedSort) {
      case 'Cena rosnąco':
        tempItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Cena malejąco':
        tempItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Nazwa A-Z':
        tempItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'Nazwa Z-A':
        tempItems.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    setState(() {
      filteredItems = tempItems;
    });
  }

  void _buyItem(BuildContext context, Item item) async {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: item.price,
          onPaymentSuccess: (method) async {
            try {
              final db = AppDatabase.instance;
              await db.transferSaldo(userId, item.usersId, item.price);

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
                await db.updateItem(item.id, {'quantity': 0});
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Przedmiot został kupiony przez $method!")),
              );
              context.push('/purchasedItems');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Błąd płatności: $e")),
              );
            }
          },
        ),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Szukaj po tytule',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchQuery = value;
                _applyFilters();
              },
            ),
            SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                  _applyFilters();
                }
              },
              items: categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedSort,
              onChanged: (value) {
                if (value != null) {
                  selectedSort = value;
                  _applyFilters();
                }
              },
              items: sortOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(child: Text("Brak przedmiotów do wyświetlenia"))
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text("${item.title} (${item.category})"),
                          subtitle: Text("${item.price} PLN"),
                          trailing: item.isAuction
                              ? null
                              : ElevatedButton(
                                  onPressed: () => _buyItem(context, item),
                                  child: Text("Kup"),
                                ),
                          onTap: () {
                            context.push('/itemDetails/${item.id}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
