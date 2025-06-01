import 'package:aledrogo/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

// repozytorium aka posrednik miedzy danymi 
class UserRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<int> registerUser(String name, String email, String password) async {
    return await _db.addUser(name, email, password);
  }

  Future<bool> loginUser(String email, String password) async {
    final db = await _db.database;
    final hashedPassword = _db.encode(password);

    final result = await db.query(
      AppDatabase.users_table,
      where: '${AppDatabase.users_email} = ? AND ${AppDatabase.users_password} = ?',
      whereArgs: [email, hashedPassword],
    );

    if (result.isNotEmpty){
      final shared_preferences = await SharedPreferences.getInstance();
      await shared_preferences.setString('email', email);
    }

    // jezeli wynik nie jest pusty to taki user istnieje
    return result.isNotEmpty;
  }

  Future<int?> getUserId() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final email = sharedPreferences.getString('email');
    if (email == null) return null;

    final db = AppDatabase.instance;
    final database = await db.database;
    final result = await database.query(
      AppDatabase.users_table,
      where: '${AppDatabase.users_email} = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first[AppDatabase.users_id] as int;
    }
    return null;
  }
}

Future<String?> getUserEmail() async {
  final shared_preferences = await SharedPreferences.getInstance();
  return shared_preferences.getString('email');
}

Future<Map<String, dynamic>> getUserData() async {
  final shared_preferences = await SharedPreferences.getInstance();
  final email = shared_preferences.getString('email');
  if (email == null) return {};

  final db = AppDatabase.instance;
  // Pobierz dane użytkownika
  final users = await db.getUsers();
  final user = users.firstWhere((u) => u['email'] == email, orElse: () => {});

  // Pobierz dane szczegółowe (users_data)
  final userDataList = await db.getUserData(user['id']);
  final userData = userDataList.isNotEmpty ? userDataList.first : {};

  // Połącz dane z obu tabel
  return {
    'id': user['id'],
    'name': user['name'],
    'email': user['email'],
    'city': userData['city'] ?? '',
    'street': userData['street'] ?? '',
    'house_number': userData['house_number'] ?? '',
    'phone_number': userData['phone_number'] ?? '',
    'postal_code': userData['postal_code'] ?? '',
    'saldo': userData['saldo'] ?? 0.0,
  };
}

Future<void> logout(BuildContext context) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.remove('email');
  context.go('/index');
}
