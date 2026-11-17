import 'package:flutter/material.dart';
import 'screens/geo_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeoApp());
}

class GeoApp extends StatelessWidget {
  const GeoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'GeoExplora · Semana 10',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C806F)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF3F7F6),
        ),
        home: const GeoMapScreen(),
      );
}
