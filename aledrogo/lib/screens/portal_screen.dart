import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../user_repository.dart';

class PortalScreen extends StatelessWidget {
  final String email;

  PortalScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portal użytkownika"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle, size: 40, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Zalogowano jako:", style: TextStyle(color: Colors.grey[600])),
                                SizedBox(height: 4),
                                Text(email, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text("Dostępne akcje", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: [
                      _portalButton(
                        context,
                        icon: Icons.list,
                        label: "Lista przedmiotów",
                        route: '/itemsList',
                      ),
                      _portalButton(
                        context,
                        icon: Icons.sell,
                        label: "Na sprzedaż",
                        route: '/sellList',
                      ),
                      _portalButton(
                        context,
                        icon: Icons.add_box,
                        label: "Dodaj przedmiot",
                        route: '/addItem',
                      ),
                      _portalButton(
                        context,
                        icon: Icons.shopping_bag,
                        label: "Kupione",
                        route: '/purchasedItems',
                      ),
                      _portalButton(
                        context,
                        icon: Icons.gavel,
                        label: "Licytacje",
                        route: '/auctionItems',
                      ),
                      _portalButton(
                        context,
                        icon: Icons.add_circle_outline,
                        label: "Nowa licytacja",
                        route: '/create-auction',
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _portalButton(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return ElevatedButton(
      onPressed: () => context.push(route),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
