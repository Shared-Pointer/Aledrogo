import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:crypto/crypto.dart';
import 'dart:convert';

class AppDatabase { 
  static const _name = 'aledrogo.db';
  static const _version = 1;

  //dla tabeli USERS
  static const users_table = 'users';
  static const users_id = 'id';
  static const users_name = 'name';
  static const users_email = 'email';
  static const users_password = 'password';

  //dla USERS_DATA
  static const users_data_table = 'users_data';
  static const users_data_id = 'id';
  static const users_data_user_id = 'user_id';
  static const users_data_city = 'city';
  static const users_data_street = 'street';
  static const users_data_house_number = 'house_number';
  static const users_data_phone_number = 'phone_number';
  static const users_data_postal_code = 'postal_code';
  static const users_data_saldo = 'saldo';

  //dla ITEMS
  static const items_table = 'items';
  static const items_id = 'id';
  static const items_seller_id = 'users_id';
  static const items_title = 'title';
  static const items_description = 'description';
  static const items_price = 'price';
  static const items_category = 'category';
  static const items_quantity = 'quantity'; //nwm czy ilość bedzie potrzebna
  static const items_image = 'image';
  static const items_is_auction = 'is_auction';
  static const items_end_date = 'end_date'; //data zakończenia w przypadku licytacji

  //dla TRANSACTIONS
  static const transactions_table = 'transactions';
  static const transactions_id = 'id';
  static const transactions_buyer_id = 'buyer_id';
  static const transactions_seller_id = 'seller_id';
  static const transactions_item_id = 'item_id';
  static const transactions_price = 'price'; //nwm czy potrzebujemy ceny tutaj
  static const transactions_date = 'date';

  //dla AUCTIONS
  static const auctions_table = 'auctions';
  static const auctions_id = 'id';
  static const auctions_item_id = 'item_id';
  static const auctions_buyer_id = 'buyer_id';
  static const auctions_price = 'price';
  static const auctions_date = 'date';

  static final AppDatabase _instance = AppDatabase._init(); //final oznacza że istnieje tylko jedna kopia tej instancji w całej apce
  static Database? _database; //nullable, bo na początku nie ma bazy
  AppDatabase._init(); //konstruktor prywatny, uniemożliwia tworzenie instancji tej klasy poza nią samą

  //metoda inicjalizująca bazę danych
  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath(); //ścieżka do bazy danych
    final path = join(dbPath, dbName); //łączenie ścieżki z nazwą bazy danych
    return openDatabase(path, version: _version, onCreate: _createDB); //otwarcie bazy danych
  }

  Future<void> _createDB(Database db, int version) async {

  }
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('aledrogo.db');
    return _database!;
  }




}