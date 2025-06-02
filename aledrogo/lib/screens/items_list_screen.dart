import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
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

Widget _buildSearchField() {
  return TextField(
    decoration: InputDecoration(
      hintText: 'Szukaj po tytule...',
      prefixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    onChanged: (value) {
      setState(() {
        searchQuery = value;
        _applyFilters();
      });
    },
  );
}

Widget _buildDropdown(List<String> items, String selectedValue, Function(String) onChanged) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButton<String>(
      value: selectedValue,
      isExpanded: true,
      underline: SizedBox(),
      icon: Icon(Icons.arrow_drop_down),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
    ),
  );
}

Widget _buildItemCard(Item item) {
  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () {
        context.push('/itemDetails/${item.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.image.toString().isNotEmpty
                  ? Image.file(
                      File(item.image),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(item.category, style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text("${item.price.toStringAsFixed(2)} PLN",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (!item.isAuction)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _buyItem(context, item),
                child: Text("Kup"),
              ),
          ],
        ),
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF5F5F5),
    appBar: AppBar(
      title: Text("Lista przedmiotów"),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchField(),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDropdown(categories, selectedCategory, (val) {
                setState(() => selectedCategory = val);
                _applyFilters();
              })),
              SizedBox(width: 8),
              Expanded(child: _buildDropdown(sortOptions, selectedSort, (val) {
                setState(() => selectedSort = val);
                _applyFilters();
              })),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(child: Text("Brak przedmiotów do wyświetlenia"))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildItemCard(item);
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

}
