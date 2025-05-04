import 'dart:io';

import 'package:flutter/material.dart';
import '../database.dart';
import '../user_repository.dart';

class AuctionItemsScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchAuctionItems() async {
    final db = await AppDatabase.instance.database;
    return await db.rawQuery('''
      SELECT 
        a.${AppDatabase.auctions_id} AS auction_id,
        a.${AppDatabase.auctions_item_id} AS item_id,
        a.${AppDatabase.auctions_buyer_id} AS buyer_id,
        a.${AppDatabase.auctions_price} AS price,
        a.${AppDatabase.auctions_date} AS end_date,
        i.${AppDatabase.items_title} AS title,
        i.${AppDatabase.items_description} AS description,
        i.${AppDatabase.items_image} AS image,
        i.${AppDatabase.items_category} AS category
      FROM ${AppDatabase.auctions_table} a
      INNER JOIN ${AppDatabase.items_table} i ON a.${AppDatabase.auctions_item_id} = i.${AppDatabase.items_id}
    ''');
  }

  void _navigateToAuctionDetails(BuildContext context, Map<String, dynamic> auction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuctionDetailsScreen(auction: auction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Przedmioty na licytacji")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAuctionItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Brak przedmiotów na licytacji"));
          } else {
            final auctions = snapshot.data!;
            return ListView.builder(
              itemCount: auctions.length,
              itemBuilder: (context, index) {
                final auction = auctions[index];
                return ListTile(
                  title: Text(auction['title'] ?? "Brak tytułu"),
                  subtitle: Text("Cena: ${auction['price']} PLN"),
                  trailing: Text("Data zakończenia: ${auction['end_date']}"),
                  onTap: () => _navigateToAuctionDetails(context, auction),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class AuctionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> auction;

  AuctionDetailsScreen({required this.auction});

  void _placeBid(BuildContext context) async {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
      );
      return;
    }

    final newPrice = auction['price'] + 10; // Minimalne podbicie o 10 zł
    final db = AppDatabase.instance;
    await db.placeBid(auction['auction_id'], userId, newPrice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Oferta została złożona")),
    );

    Navigator.of(context).pop(); // Powrót do listy aukcji
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Szczegóły licytacji")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tytuł: ${auction['title']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Opis: ${auction['description']}"),
            SizedBox(height: 8),
            if (auction['image'] != null && auction['image'].toString().isNotEmpty)
              Image.file(File(auction['image'])),
            SizedBox(height: 8),
            Text("Kategoria: ${auction['category']}"),
            SizedBox(height: 8),
            Text("Cena aktualna: ${auction['price']} PLN"),
            SizedBox(height: 8),
            Text("Data zakończenia: ${auction['end_date']}"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeBid(context),
              child: Text("Złóż ofertę (+10 PLN)"),
            ),
          ],
        ),
      ),
    );
  }
}