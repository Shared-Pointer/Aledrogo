import 'package:aledrogo/navbar.dart';
import 'package:aledrogo/screens/index.dart';
import 'package:aledrogo/screens/login.dart';
import 'package:aledrogo/screens/portal_screen.dart';
import 'package:aledrogo/screens/welcome_screen.dart';
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
        path:'/index',
        name:'index',
        builder: (context,state) => Index(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context,state) => LoginScreen(), 
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
                builder: (context, state) => WelcomeScreenWithNavbar(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/options',
                name: 'options',
                builder: (context, state) => WelcomeScreenWithNavbar(),
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
