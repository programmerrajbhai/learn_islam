import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Terms & Conditions'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF145444),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Last updated: September 2026', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 24),
                  _Section(
                    title: '1. Introduction',
                    content: 'Welcome to Learn Islam: Islam Quiz. By using our app, you agree to these terms. Please read them carefully before using the application.',
                  ),
                  _Section(
                    title: '2. User Accounts',
                    content: 'You are responsible for maintaining the confidentiality of your account credentials. You must provide accurate information when registering.',
                  ),
                  _Section(
                    title: '3. Premium Coins & Purchases',
                    content: 'Any coins purchased within the app (In-App Purchases) are final and non-refundable. Coins are meant to unlock premium quizzes and have no real-world monetary value.',
                  ),
                  _Section(
                    title: '4. Acceptable Use',
                    content: 'You agree not to misuse the app, exploit bugs, or attempt to hack the premium features or quiz answers. We reserve the right to suspend accounts that violate these terms.',
                  ),
                  _Section(
                    title: '5. Modifications',
                    content: 'We reserve the right to modify these terms at any time. Continued use of the app constitutes your consent to such changes.',
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF19332D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.5),
          ),
        ],
      ),
    );
  }
}