import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/monitoring_service.dart';
import 'services/cart_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Monitoring (Non-blocking to avoid blank screen)
  final monitor = MonitoringService();
  monitor.trackHealth('online').catchError((e) => print('Monitoring error: $e'));
  monitor.trackBehavior('app_launch', 'main_screen').catchError((e) => print('Monitoring error: $e'));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
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
      title: 'Novara Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF0E9594), // Electrical Teal
          onPrimary: Colors.white,
          secondary: Color(0xFF151515), // Charcoal
          onSecondary: Colors.white,
          tertiary: Color(0xFFF5DF4D), // Accent Yellow
          onTertiary: Color(0xFF151515),
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          background: Color(0xFFF8F9FA),
          onBackground: Color(0xFF151515),
          surface: Colors.white,
          onSurface: Color(0xFF151515),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF151515),
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E9594),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
