import 'package:flutter/material.dart';
import 'package:prayer_basket_2/pages/app_shell.dart';
import 'package:prayer_basket_2/services/database_helper.dart';
import 'package:prayer_basket_2/services/prayer_provider_service.dart';
import 'package:prayer_basket_2/services/theme_provider_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DB on app startup
  await DatabaseHelper.instance.database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().currentTheme,
      home: const AppShell(), // The entry point is now the shell
    );
  }
}