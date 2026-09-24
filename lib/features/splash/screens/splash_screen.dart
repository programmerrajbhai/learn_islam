import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

import '../../auth/services/auth_service.dart';
import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    AppUser? user;
    try {
      user = await authService.currentUser();
    } catch (_) {
      user = null;
    }

    if (!mounted) return;

    final Widget nextScreen = user == null
        ? const WelcomeScreen()
        : HomeScreen(user: user);

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return const AppBackground(
      dark: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFE8D69A),
                  size: 76,
                ),
                SizedBox(height: 22),
                Text(
                  'Learn Islam',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Islam Quiz',
                  style: TextStyle(color: Colors.white70, fontSize: 17),
                ),
                SizedBox(height: 48),
                CircularProgressIndicator(color: Color(0xFFE8D69A)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
