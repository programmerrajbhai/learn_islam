import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Privacy Policy'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text(
                    'Privacy Policy',
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
                    title: '1. Information We Collect',
                    content: 'When you register, we collect your Name and Email address via Google Firebase Authentication to create and secure your profile. We also save your quiz progress locally and on our servers.',
                  ),
                  _Section(
                    title: '2. How We Use Your Data',
                    content: 'We use your data to provide a personalized experience, track your learning progress, and manage your premium coin balance. We do not sell your personal data to any third parties.',
                  ),
                  _Section(
                    title: '3. Data Security',
                    content: 'Your data is securely stored using Google Firebase. We implement standard security measures to ensure your information is safe from unauthorized access.',
                  ),
                  _Section(
                    title: '4. Account Deletion',
                    content: 'You can delete your account and all associated data at any time from the "Profile > Delete Account" section inside the app, or by contacting us via our website.',
                  ),
                  _Section(
                    title: '5. Contact Us',
                    content: 'If you have any questions regarding this Privacy Policy, please contact us at: support@programmerraj.site',
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