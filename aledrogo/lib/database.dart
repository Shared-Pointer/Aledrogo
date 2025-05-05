import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AppDatabase { 
  static const _name = 'aledrogo.db';
  static const _version = 3;

  // Tabela USERS
  static const users_table = 'users';
  static const users_id = 'id';
  static const users_name = 'name';
  static const users_email = 'email';
  static const users_password = 'password';

  // Tabela USERS_DATA
  static const users_data_table = 'users_data';
  static const users_data_id = 'id';
  static const users_data_user_id = 'user_id';
  static const users_data_city = 'city';
  static const users_data_street = 'street';
  static const users_data_house_number = 'house_number';
  static const users_data_phone_number = 'phone_number';
  static const users_data_postal_code = 'postal_code';
  static const users_data_saldo = 'saldo';

  // Tabela ITEMS
  static const items_table = 'items';
  static const items_id = 'id';
  static const items_seller_id = 'users_id';
  static const items_title = 'title';
  static const items_description = 'description';
  static const items_price = 'price';
  static const items_category = 'category';
  static const items_quantity = 'quantity';
  static const items_image = 'image';
  static const items_is_auction = 'is_auction';
  static const items_end_date = 'end_date';

  // Tabela TRANSACTIONS
  static const transactions_table = 'transactions';
  static const transactions_id = 'id';
  static const transactions_buyer_id = 'buyer_id';
  static const transactions_seller_id = 'seller_id';
  static const transactions_item_id = 'item_id';
  static const transactions_price = 'price';
  static const transactions_date = 'date';

  // Tabela AUCTIONS
  static const auctions_table = 'auctions';
  static const auctions_id = 'id';
  static const auctions_item_id = 'item_id';
  static const auctions_buyer_id = 'buyer_id';
  static const auctions_price = 'price';
  static const auctions_date = 'date';

  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(path, 
      version: _version, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $users_table (
        $users_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $users_name TEXT NOT NULL UNIQUE,
        $users_email TEXT NOT NULL UNIQUE,
        $users_password TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $users_data_table (
        $users_data_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $users_data_user_id INTEGER NOT NULL,
        $users_data_city TEXT NOT NULL,
        $users_data_street TEXT NOT NULL,
        $users_data_house_number TEXT NOT NULL,
        $users_data_phone_number TEXT NOT NULL,
        $users_data_postal_code TEXT NOT NULL,
        $users_data_saldo REAL,
        FOREIGN KEY ($users_data_user_id) REFERENCES $users_table($users_id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $items_table (
        $items_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $items_seller_id INTEGER NOT NULL,
        $items_title TEXT NOT NULL,
        $items_description TEXT,
        $items_price REAL NOT NULL,
        $items_category TEXT CHECK( $items_category IN ('Odzież','Elektronika','Obuwie','Zabawki','Kolekcjonerskie','AGD/RTV','Konsole i Gry','Inne') ) NOT NULL DEFAULT 'Inne',
        $items_quantity INTEGER,
        $items_image TEXT,
        $items_is_auction INTEGER,
        $items_end_date TEXT,
        FOREIGN KEY ($items_seller_id) REFERENCES $users_table($users_id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $transactions_table (
        $transactions_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $transactions_buyer_id INTEGER NOT NULL,
        $transactions_seller_id INTEGER NOT NULL,
        $transactions_item_id INTEGER NOT NULL,
        $transactions_price REAL NOT NULL,
        $transactions_date TEXT NOT NULL,
        FOREIGN KEY ($transactions_buyer_id) REFERENCES $users_table($users_id),
        FOREIGN KEY ($transactions_seller_id) REFERENCES $users_table($users_id),
        FOREIGN KEY ($transactions_item_id) REFERENCES $items_table($items_id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE $auctions_table (
        $auctions_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $auctions_item_id INTEGER NOT NULL,
        $auctions_buyer_id INTEGER NOT NULL,
        $auctions_price REAL NOT NULL,
        $auctions_date TEXT NOT NULL,
        FOREIGN KEY ($auctions_item_id) REFERENCES $items_table($items_id),
        FOREIGN KEY ($auctions_buyer_id) REFERENCES $users_table($users_id)
      )
    ''');
  }

  //migracja typpu: kopiowanie do tempowej tabeli usuniecie starej i zmiana nazwy tempowej na prawidłowa :3
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print("----------------Upgrading database from version $oldVersion to $newVersion");
  if (oldVersion < 2) {
    await db.execute('''
      CREATE TABLE items_temp (
        $items_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $items_seller_id INTEGER NOT NULL,
        $items_title TEXT NOT NULL,
        $items_description TEXT,
        $items_price REAL NOT NULL,
        $items_category TEXT CHECK($items_category IN ('Odzież','Elektronika','Obuwie','Zabawki','Kolekcjonerskie','AGD/RTV','Konsole i Gry','Inne')) NOT NULL DEFAULT 'Inne',
        $items_quantity INTEGER,
        $items_image TEXT,
        $items_is_auction INTEGER,
        $items_end_date TEXT,
        FOREIGN KEY ($items_seller_id) REFERENCES $users_table($users_id)
      )
    ''');

    await db.execute('''
      INSERT INTO items_temp (
        $items_id, $items_seller_id, $items_title, $items_description,
        $items_price, $items_category, $items_quantity, $items_image,
        $items_is_auction, $items_end_date
      )
      SELECT
        $items_id, $items_seller_id, $items_title, $items_description,
        $items_price, $items_category, $items_quantity, $items_image,
        $items_is_auction, $items_end_date
      FROM $items_table
    ''');

    await db.execute('DROP TABLE $items_table');

    await db.execute('ALTER TABLE items_temp RENAME TO $items_table');

  if (oldVersion < 3) {
    print("----------------Adding new columns to auctions table");
    await db.execute('''
      ALTER TABLE $auctions_table ADD COLUMN title TEXT;
    ''');
    await db.execute('''
      ALTER TABLE $auctions_table ADD COLUMN description TEXT;
    ''');
    await db.execute('''
      ALTER TABLE $auctions_table ADD COLUMN category TEXT;
    ''');
    await db.execute('''
      ALTER TABLE $auctions_table ADD COLUMN image TEXT;
    ''');
  }
  }
}

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aledrogo.db');
    return _database!;
  }

  String encode(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> addUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert(users_table, {
      users_name: name,
      users_email: email,
      users_password: encode(password)
    });
  }

  Future<int> addUserData(int userId, String city, String street, String houseNumber, String phoneNumber, String postalCode, double saldo) async {
    final db = await database;
    return await db.insert(users_data_table, {
      users_data_user_id: userId,
      users_data_city: city,
      users_data_street: street,
      users_data_house_number: houseNumber,
      users_data_phone_number: phoneNumber,
      users_data_postal_code: postalCode,
      users_data_saldo: saldo
    });
  }

  Future<int> addItems(int usersId, String title, String description, double price, String category, int quantity, String image, int isAuction, String endDate) async {
    final db = await database;
    return await db.insert(items_table, {
      items_seller_id: usersId,
      items_title: title,
      items_description: description,
      items_price: price,
      items_category: category,
      items_quantity: quantity,
      items_image: image,
      items_is_auction: isAuction,
      items_end_date: endDate
    });
  }

  Future<int> addTransaction(int buyerId, int sellerId, int itemId, double price, String date) async {
    final db = await database;
    final success = await db.insert(transactions_table, {
      transactions_buyer_id: buyerId,
      transactions_seller_id: sellerId,
      transactions_item_id: itemId,
      transactions_price: price,
      transactions_date: date
    });
    print("Transaction added: $success");
    return success;
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query(transactions_table);
  }

  // Future<int> addAuction(int itemId, int buyerId, double price, String date) async {
  //   final db = await database;
  //   return await db.insert(auctions_table, {
  //     auctions_item_id: itemId,
  //     auctions_buyer_id: buyerId,
  //     auctions_price: price,
  //     auctions_date: date
  //   });
  // }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query(users_table);
  }

  Future<List<Map<String, dynamic>>> getUserData(int userId) async {
    final db = await database;
    return await db.query(users_data_table, where: '$users_data_user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query(items_table);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query(transactions_table);
  }

  Future<List<Map<String, dynamic>>> getAuctions() async {
    final db = await database;
    return await db.query(auctions_table);
  }

  Future<int> addItem(Map<String, dynamic> itemData) async {
    final db = await database;
    return await db.insert(items_table, {
      items_title: itemData['title'],
      items_description: itemData['description'],
      items_price: itemData['price'],
      items_seller_id: itemData['users_id'],
      items_category: itemData['category'],
      items_quantity: itemData['quantity'],
      items_image: itemData['image'],
      items_is_auction: itemData['is_auction'],
      items_end_date: itemData['end_date'],
    });
  }

  Future<int> updateItem(int id, Map<String, dynamic> itemData) async {
    final db = await database;
    return await db.update(items_table, itemData, where: '$items_id = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(items_table, where: '$items_id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAvailableItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM $items_table
      WHERE $items_quantity > 0
      AND $items_id NOT IN (SELECT $auctions_item_id FROM $auctions_table)
    ''');
  }

  Future<List<Map<String, dynamic>>> getPurchasedItems(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT i.*
      FROM $items_table i
      INNER JOIN $transactions_table t ON i.$items_id = t.$transactions_item_id
      WHERE t.$transactions_buyer_id = ?
    ''', [userId]);
    print("Purchased items for user $userId: $result");
    return result;
  }

  Future<List<Map<String, dynamic>>> getItemDetails(int itemId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT *
      FROM $items_table
      WHERE $items_id = ?
    ''', [itemId]);
    print("Item details for: $result");
    return result;
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(transactions_table);
    print("Baza danych została wyczyszczona.");
  }


  Future<void> addAuction(Map<String, dynamic> auctionData) async {
    final db = await instance.database;
    await db.insert('auctions', auctionData);
  }

  Future<void> placeBid(int auctionId, int userId, double newPrice) async {
    final db = await database;
    await db.update(
      auctions_table,
      {
        'price': newPrice,
        'buyer_id': userId,
      },
      where: '$auctions_id = ?',
      whereArgs: [auctionId],
    );
  }

  Future<void> finalizeAuction(int auctionId) async {
    final db = await instance.database;
    final auction = await db.query(
      'auctions',
      where: 'id = ?',
      whereArgs: [auctionId],
    );
    if (auction.isNotEmpty) {
      final winnerId = auction.first['current_bidder_id'];
      final itemId = auction.first['item_id'];
      await db.insert('purchased_items', {
        'user_id': winnerId,
        'item_id': itemId,
      });
      await db.delete('auctions', where: 'id = ?', whereArgs: [auctionId]);
    }
  }
}
