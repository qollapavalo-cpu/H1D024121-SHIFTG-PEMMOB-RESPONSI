// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => WeatherViewModel(
      weatherService: WeatherService(),
      storageService: LocalStorageService(),
    )..initialize(),
    child: const CuacaApp(),
  ));
}

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Langit • Cuaca',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2158B0)),
          scaffoldBackgroundColor: const Color(0xFFF3F6FB),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF3F6FB),
            centerTitle: false,
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(fontWeight: FontWeight.w800),
            titleLarge: TextStyle(fontWeight: FontWeight.w700),
            bodyMedium: TextStyle(height: 1.5),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        home: const WeatherScreen(),
      );
}
