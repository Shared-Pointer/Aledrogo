import 'package:aledrogo/database.dart';

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

    // jezeli wynik nie jest pusty to taki user istnieje
    return result.isNotEmpty;
  }
}
