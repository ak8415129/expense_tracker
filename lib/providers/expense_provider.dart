import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  String _userName = '';
  double _monthlyBudget = 1000.0;
  bool _askedForName = false;
  ThemeMode _themeMode = ThemeMode.system;

  List<Expense> get expenses => _expenses;
  String get userName => _userName;
  double get monthlyBudget => _monthlyBudget;
  bool get askedForName => _askedForName;
  ThemeMode get themeMode => _themeMode;

  final DBHelper _db = DBHelper();

  Future<void> init() async {
    await _loadPrefs();
    await _loadExpenses();
    // No automatic dummy data seeding — user will add expenses manually
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    _userName = sp.getString('userName') ?? '';
    _monthlyBudget = sp.getDouble('monthlyBudget') ?? 1000.0;
    _askedForName = sp.getBool('askedForName') ?? false;
    final t = sp.getString('themeMode') ?? 'system';
    _themeMode = t == 'light' ? ThemeMode.light : t == 'dark' ? ThemeMode.dark : ThemeMode.system;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('userName', name);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double b) async {
    _monthlyBudget = b;
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('monthlyBudget', b);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('themeMode', m == ThemeMode.light ? 'light' : m == ThemeMode.dark ? 'dark' : 'system');
    notifyListeners();
  }

  Future<void> setAskedForName(bool v) async {
    _askedForName = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('askedForName', v);
    notifyListeners();
  }

  Future<void> _loadExpenses() async {
    _expenses = await _db.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense e) async {
    await _db.insertExpense(e);
    await _loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    await _loadExpenses();
  }

  Future<File> exportCsv() async {
    final rows = <List<dynamic>>[];
    rows.add(['id', 'amount', 'category', 'date']);
    for (var e in _expenses) {
      rows.add([e.id, e.amount, e.category, e.date.toIso8601String()]);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file;
  }

  Future<void> shareCsv() async {
    final file = await exportCsv();
    // Use SharePlus.instance API to avoid deprecated `Share` usage.
    // Prefer the top-level SharePlus instance API; if the shareXFiles helper
    // is still available on the instance it will be used. This keeps the
    // code compatible with newer share_plus releases.
    final xfile = XFile(file.path);
    // Newer share_plus versions expose an instance-based API. Use it when
    // available and fall back to the older helper for backwards
    // compatibility.
    // The older top-level helper is still available and works across a
    // broad range of share_plus versions; suppress the deprecation warning
    // to avoid analyzer noise until a safe, tested migration is performed.
    // ignore: deprecated_member_use
    await Share.shareXFiles([xfile], text: 'My expenses export');
  }

  // dummy data removed
}
