import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/pages/home_page.dart'; 
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  // Initialize Google Mobile Ads and print status to help debug ad loading.
  final initStatus = await MobileAds.instance.initialize();
  debugPrint('MobileAds initialized: $initStatus');

  // Add test device IDs if needed (replace with your emulator/device ID when known).
  // Example: RequestConfiguration(testDeviceIds: ['YOUR_DEVICE_ID_HERE']);
  MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
    testDeviceIds: <String>[],
  ));
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
