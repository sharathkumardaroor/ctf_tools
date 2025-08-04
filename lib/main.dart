import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/file_analysis_provider.dart';
import 'providers/ctf_challenge_provider.dart';

void main() {
  runApp(const CTFAnalyzerApp());
}

class CTFAnalyzerApp extends StatelessWidget {
  const CTFAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => CTFChallengeProvider()),
      ],
      child: MaterialApp(
        title: 'CTF Analyzer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D4FF),
            brightness: Brightness.dark,
            primary: const Color(0xFF00D4FF),
            secondary: const Color(0xFF7C3AED),
            surface: const Color(0xFF161B22),
            background: const Color(0xFF0D1117),
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          cardTheme: const CardThemeData(
            color: Color(0xFF161B22),
            elevation: 8,
            shadowColor: Color(0xFF00D4FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              side: BorderSide(color: Color(0xFF21262D), width: 1),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: const Color(0xFF0D1117),
              elevation: 4,
              shadowColor: const Color(0xFF00D4FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          chipTheme: const ChipThemeData(
            backgroundColor: Color(0xFF21262D),
            selectedColor: Color(0xFF00D4FF),
            labelStyle: TextStyle(color: Colors.white),
            side: BorderSide(color: Color(0xFF30363D)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF21262D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF30363D)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 2),
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}