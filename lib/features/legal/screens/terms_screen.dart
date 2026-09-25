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
                    'Learn Islam — Terms & Conditions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Last updated: 25 September 2026'),
                  SizedBox(height: 24),
                  _Section(
                    title: '1. App ব্যবহার',
                    content: 'Learn Islam একটি শিক্ষামূলক quiz app। '
                        'প্রশ্ন ও ব্যাখ্যার সঙ্গে দেওয়া উৎস দেখে '
                        'তথ্য যাচাই করুন। ব্যক্তিগত ধর্মীয় বিধানের '
                        'জন্য যোগ্য জ্ঞানীর পরামর্শ নিন।',
                  ),
                  _Section(
                    title: '2. Account',
                    content: 'নিজের account-এর login তথ্য সুরক্ষিত রাখুন। '
                        'অন্যের account ব্যবহার বা app-এর কার্যক্রমে '
                        'অননুমোদিত হস্তক্ষেপ করবেন না।',
                  ),
                  _Section(
                    title: '3. Coin ও premium quiz',
                    content: 'Google Play Billing দিয়ে coin কেনা যায়। '
                        'App-এ দেখানো স্থানীয় দাম অনুযায়ী payment হবে। '
                        'Coin-এর কোনো নগদ মূল্য নেই এবং app-এর বাইরে '
                        'transfer করা যায় না। একটি premium quiz একবার '
                        'coin দিয়ে unlock করলে একই account-এ আবার '
                        'খেলতে coin লাগে না।',
                  ),
                  _Section(
                    title: '4. Purchase সমস্যা ও refund',
                    content: 'Payment সফল হলেও coin না পেলে purchase ID '
                        'সহ support-এ যোগাযোগ করুন; একই purchase আবার '
                        'করবেন না। Refund request ও সিদ্ধান্ত Google '
                        'Play-এর প্রক্রিয়া এবং প্রযোজ্য নিয়ম অনুযায়ী হবে।',
                  ),
                  _Section(
                    title: '5. Account মুছে ফেলা',
                    content: 'Profile > Delete Account থেকে account '
                        'মুছতে পারবেন। Account মুছলে অব্যবহৃত coin '
                        'ও premium quiz access হারাবেন। Google Play-এর '
                        'নিজস্ব order record app থেকে মুছে ফেলা যায় না।',
                  ),
                  _Section(
                    title: '6. যোগাযোগ',
                    content: 'Email: novatechsoft668@outlook.com',
                  ),
                  SizedBox(height: 32),
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
  const _Section({
    required this.title,
    required this.content,
  });

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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}