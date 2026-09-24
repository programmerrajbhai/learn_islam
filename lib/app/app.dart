import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/screens/splash_screen.dart';

class LearnIslamApp extends StatelessWidget {
  const LearnIslamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Islam: Islam Quiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}