import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Firebase Auth
import 'package:firebase_core/firebase_core.dart'; // 👈 Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Add kiya
import 'controllers/map_controller.dart';
import 'controllers/tts_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 NAYA FIX: Check karo ki Firebase pehle se start hai ya nahi
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDQ1qSypT3u0X-H_aEoiekjlNwLOYmTGqE",
            authDomain: "a-bodhi-citta.firebaseapp.com",
            projectId: "a-bodhi-citta",
            storageBucket: "a-bodhi-citta.firebasestorage.app",
            messagingSenderId: "67022605578",
            appId: "1:67022605578:web:9094c4ee6602f2a5ab7ef3",
            measurementId: "G-22R1WJDRZH"),
      );
    }
  } catch (e) {
    debugPrint("Firebase init error (ignored): $e");
  }

  // 👇 NEW: Wait for Firebase auth state to restore (esp. on web)
  try {
    await FirebaseAuth.instance
        .authStateChanges()
        .first
        .timeout(const Duration(milliseconds: 500), onTimeout: () => null);
  } catch (_) {}

  // 👈 NAYA: Firebase Offline Persistence Enable karo
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint("Firestore Settings Error: $e");
  }

  // Hive (Local Database) Initialize karein
  await Hive.initFlutter();
  await Hive.openBox('abcitta_box');

  runApp(const AbcittaApp());
}

class AbcittaApp extends StatelessWidget {
  const AbcittaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapController()..loadNodes()),
        ChangeNotifierProvider(create: (_) => TtsController()),
      ],
      child: Consumer<MapController>(builder: (context, controller, _) {
        return MaterialApp(
          title: 'abc',
          debugShowCheckedModeBanner: false,

          // 👇 ALL 4 THEMES (Light, Dark, Sepia, Zen)
          theme: controller.themeMode == 'sepia'
              ? ThemeData(
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: const Color(0xFFF4ECD8),
                  cardColor: const Color(0xFFE8DCC4),
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF8B5A2B),
                    brightness: Brightness.light,
                    surface: const Color(0xFF3E2723),
                  ),
                  useMaterial3: true,
                )
              : controller.themeMode == 'zen'
                  ? ThemeData(
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: const Color(0xFF435747),
                      cardColor: const Color(0xFF4C6150),
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFFC49B71),
                        secondary: Color(0xFFE6D5B8),
                        surface: Color(0xFFE6D5B8),
                        onSurface: Color(0xFFE6D5B8),
                        surfaceTint: Colors.transparent,
                      ),
                      useMaterial3: true,
                    )
                  : ThemeData(
                      brightness: Brightness.light,
                      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
                      cardColor: Colors.white,
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: const Color(0xFFD4A373),
                        brightness: Brightness.light,
                        surface: Colors.black87,
                      ),
                      useMaterial3: true,
                    ),
          darkTheme: controller.themeMode == 'zen'
              ? ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: const Color(0xFF435747),
                  cardColor: const Color(0xFF4C6150),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFC49B71),
                    secondary: Color(0xFFE6D5B8),
                    surface: Color(0xFFE6D5B8),
                    onSurface: Color(0xFFE6D5B8),
                    surfaceTint: Colors.transparent,
                  ),
                  useMaterial3: true,
                )
              : ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: const Color(0xFF1E1E24),
                  cardColor: const Color(0xFF2A2A35),
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFFE8D5B7),
                    brightness: Brightness.dark,
                    surface: Colors.white,
                  ),
                  useMaterial3: true,
                ),
          themeMode:
              controller.themeMode == 'dark' || controller.themeMode == 'zen'
                  ? ThemeMode.dark
                  : ThemeMode.light,
          // ... rest of MaterialApp
          // 👇 App opens directly via splash → dashboard (guest friendly)
          home: const SplashScreen(),
        );
      }),
    );
  }
}
