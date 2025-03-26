import 'package:aledrogo/destination.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('Navbar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: navigationShell.goBranch,
      indicatorColor: Theme.of(context).primaryColor,
      destinations: destination
        .map((destination) => NavigationDestination(
          icon: Icon(destination.icon),
          label: destination.label,
          selectedIcon: Icon(destination.icon, color: Colors.white),
        ))
        .toList(),
      ),
    );
}