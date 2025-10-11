import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..init(),
      child: Consumer<ExpenseProvider>(
        builder: (context, prov, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expense Tracker',
            themeMode: prov.themeMode,
            theme: ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.indigo,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark, primarySwatch: Colors.indigo),
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
