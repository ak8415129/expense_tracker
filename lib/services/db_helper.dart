import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expense_tracker/models/expense.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expenses.db');

    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        category TEXT,
        date TEXT
      )
      ''');
    });
  }

  Future<int> insertExpense(Expense e) async {
    final database = await db;
    return await database.insert('expenses', e.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final database = await db;
    final res = await database.query('expenses', orderBy: 'date DESC');
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> deleteExpense(int id) async {
    final database = await db;
    return await database.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('expenses');
  }
}
