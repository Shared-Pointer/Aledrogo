import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const destination = [
  Destination(label: 'Strona Główna', icon: Icons.home_outlined),
  Destination(label: 'Portal', icon: Icons.search),
  Destination(label: 'Opcje', icon: Icons.settings_outlined),
];