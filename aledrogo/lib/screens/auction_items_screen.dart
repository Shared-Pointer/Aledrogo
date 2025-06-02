import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    backgroundColor: Color(0xFFFFFFFF),
    appBar: AppBar(
      title: Text("Przedmioty na licytacji"),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
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
          return ListView.separated(
            padding: EdgeInsets.all(16),
            separatorBuilder: (_, __) => SizedBox(height: 16),
            itemCount: auctions.length,
            itemBuilder: (context, index) {
              final auction = auctions[index];
              return GestureDetector(
                onTap: () => _navigateToAuctionDetails(context, auction),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: auction['image'] != null &&
                                    auction['image'].toString().isNotEmpty
                                ? Image.file(
                                    File(auction['image']),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: Icon(Icons.image_not_supported,
                                        size: 40, color: Colors.grey.shade600),
                                  ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auction['title'] ?? "Brak tytułu",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Cena: ${auction['price']} PLN",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Koniec: ${formatDate(auction['end_date'])}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    ),
  );
}

String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  } catch (e) {
    return dateStr;
  }
}

}
class AuctionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> auction;

  AuctionDetailsScreen({required this.auction});

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return isoString;
    }
  }

  void _placeBid(BuildContext context) async {
    final userId = await UserRepository().getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd: Nie można znaleźć zalogowanego użytkownika")),
      );
      return;
    }

    final newPrice = auction['price'] + 10;
    final db = AppDatabase.instance;
    await db.placeBid(auction['auction_id'], userId, newPrice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Oferta została złożona")),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text("Szczegóły licytacji"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                if (auction['image'] != null && auction['image'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(auction['image']),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  ),
                SizedBox(height: 16),
                Text(
                  auction['title'] ?? "Brak tytułu",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  auction['description'] ?? "",
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Kategoria: ${auction['category']}"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Cena: ${auction['price']} PLN",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Zakończenie: ${_formatDate(auction['end_date'])}"),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _placeBid(context),
                  icon: Icon(Icons.gavel),
                  label: Text("Złóż ofertę (+10 PLN)"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
