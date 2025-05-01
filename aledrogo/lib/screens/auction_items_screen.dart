import 'package:flutter/material.dart';
import '../database.dart';

class AuctionItemsScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchAuctionItems() async {
    final db = AppDatabase.instance;
    return await db.getAuctions();
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

  void _placeBid(BuildContext context) {
    // Implementacja składania oferty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Oferta została złożona")),
    );
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
            Text("Cena początkowa: ${auction['price']} PLN"),
            SizedBox(height: 8),
            Text("Data zakończenia: ${auction['end_date']}"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _placeBid(context),
              child: Text("Złóż ofertę"),
            ),
          ],
        ),
      ),
    );
  }
}