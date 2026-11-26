import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_theme.dart';
import 'screens/mainscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');
  ThemeMode initialTheme = ThemeMode.system;
  if (savedTheme == 'dark') {
    initialTheme = ThemeMode.dark;
  } else if (savedTheme == 'light') {
    initialTheme = ThemeMode.light;
  }
  MyApp.themeNotifier.value = initialTheme;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Global static notifier to change themes from anywhere in the app
  static final ValueNotifier<ThemeMode> themeNotifier = 
      ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Top Prompt',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          
          home: MainScreen(
            themeMode: currentMode,
            onThemeChanged: (mode) async {
              MyApp.themeNotifier.value = mode;
              final prefs = await SharedPreferences.getInstance();
              if (mode == ThemeMode.dark) {
                await prefs.setString('theme_mode', 'dark');
              } else if (mode == ThemeMode.light) {
                await prefs.setString('theme_mode', 'light');
              } else {
                await prefs.setString('theme_mode', 'system');
              }
            },
          ),
        );
      },
    );
  }
}
