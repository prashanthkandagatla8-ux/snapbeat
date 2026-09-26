import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The app opens on the dark splash, so start with the dark-background style.
  // SplashScreen swaps to AppTheme.ceramicOverlay when it hands off to Home.
  SystemChrome.setSystemUIOverlayStyle(AppTheme.splashOverlay);
  runApp(const SnapBeatApp());
}

class SnapBeatApp extends StatelessWidget {
  const SnapBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapBeat Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.retroMetalClassic,
      home: const SplashScreen(),
    );
  }
}
