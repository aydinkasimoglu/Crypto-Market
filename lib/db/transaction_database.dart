import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/crypto_transaction.dart';

class TransactionDatabase {
  static final TransactionDatabase instance = TransactionDatabase._init();

  static Database? _database;

  TransactionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase('transaction.db');
    return _database!;
  }

  /// Open the database at a given path.
  Future<Database> _initDatabase(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Create the database table. If the table already exists, do nothing.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableCryptoTransaction (
        ${CryptoTransactionFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${CryptoTransactionFields.currency} TEXT NOT NULL,
        ${CryptoTransactionFields.price} REAL NOT NULL,
        ${CryptoTransactionFields.amount} REAL NOT NULL,
        ${CryptoTransactionFields.date} TEXT NOT NULL,
        ${CryptoTransactionFields.type} TEXT NOT NULL
      )
    ''');
  }

  /// Insert a CryptoTransaction into the database and return it afterwards.
  Future<CryptoTransaction> create(CryptoTransaction transaction) async {
    final db = await instance.database;
    final id = await db.insert(tableCryptoTransaction, transaction.toJson());
    return transaction.copyWith(id: id);
  }

  /// Get a transaction by id from the database.
  Future<CryptoTransaction> getTransaction(int id) async {
    final db = await instance.database;
    final result = await db.query(tableCryptoTransaction,
        columns: CryptoTransactionFields.values,
        where: '${CryptoTransactionFields.id} = ?',
        whereArgs: [id]);
    return result.isNotEmpty
        ? CryptoTransaction.fromJson(result.first)
        : throw Exception('Transaction $id not found');
  }

  /// Get all transactions from the database and return as a List of CryptoTransaction objects.
  Future<List<CryptoTransaction>> getTransactions() async {
    final db = await instance.database;
    final result = await db.query(tableCryptoTransaction,
        columns: CryptoTransactionFields.values);
    return result.map((json) => CryptoTransaction.fromJson(json)).toList();
  }

  /// Group all transactions by currency and return as a Map of currency to List of CryptoTransaction objects.
  Future<List<CryptoTransaction>> getTransactionsGroupedByCurrency() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT ${CryptoTransactionFields.currency}, SUM(${CryptoTransactionFields.amount}) 
      FROM $tableCryptoTransaction 
      GROUP BY ${CryptoTransactionFields.currency}
    ''');
    return result.map((json) => CryptoTransaction.fromJson(json)).toList();
  }

  /// Delete a transaction by id from the database. Returns the number of rows deleted.
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(tableCryptoTransaction,
        where: '${CryptoTransactionFields.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    (await instance.database).close();
  }
}
