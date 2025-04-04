import 'package:aledrogo/navbar.dart';
import 'package:aledrogo/screens/index.dart';
import 'package:aledrogo/screens/items_list_screen.dart';
import 'package:aledrogo/screens/purchased_items_screen.dart';
import 'package:aledrogo/screens/login.dart';
import 'package:aledrogo/screens/options_screen.dart';
import 'package:aledrogo/screens/portal_screen.dart';
import 'package:aledrogo/screens/sell_screen.dart';
import 'package:aledrogo/screens/welcome_screen.dart';
import 'package:aledrogo/screens/add_item_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _parentKey = GlobalKey<NavigatorState>();

Future<String> getEmail() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString('email') ?? '';
}

GoRouter goRouter() {
  return GoRouter(
    initialLocation: '/index',
    navigatorKey: _parentKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/index',
        name: 'index',
        builder: (context, state) => Index(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/itemsList',
        name: 'itemsList',
        builder: (context, state) => ItemsListScreenWithNavbar(),
      ),
      GoRoute(
        path: '/purchasedItems',
        name: 'purchasedItems',
        builder: (context, state) => PurchasedItemsScreen(),
      ),
      GoRoute(
        path: '/sellList',
        name: 'sellList',
        builder: (context, state) => SellListScreenWithNavbar(),
      ),
      GoRoute(
        path: '/addItem',
        name: 'addItem',
        builder: (context, state) => AddItemScreenWithNavbar(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => Navbar(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/welcome',
                name: 'welcome',
                builder: (context, state) => WelcomeScreenWithNavbar(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portal',
                name: 'portal',
                builder: (context, state) => PortalScreenWithNavbar(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/options',
                name: 'options',
                builder: (context, state) => OptionsScreenWithNavbar(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class WelcomeScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          final email = snapshot.data ?? '';
          return WelcomeScreen(email: email);
        }
      },
    );
  }
}

class PortalScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          final email = snapshot.data ?? '';
          return PortalScreen(email: email);
        }
      },
    );
  }
}

class OptionsScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          final email = snapshot.data ?? '';
          return OptionsScreen(email: email);
        }
      },
    );
  }
}

class ItemsListScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          //final email = snapshot.data ?? '';
          return ItemListScreen();
        }
      },
    );
  }
}

class SellListScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          final email = snapshot.data ?? '';
          return SellListScreen(email: email);
        }
      },
    );
  }
}

class AddItemScreenWithNavbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        } else {
          //final email = snapshot.data ?? '';
          return AddItemScreen();
        }
      },
    );
  }
}