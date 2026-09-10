import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE8E4DC),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SnapBeatApp());
}

class SnapBeatApp extends StatelessWidget {
  const SnapBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapBeat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.retroMetalClassic,
      home: const HomeScreen(),
    );
  }
}
