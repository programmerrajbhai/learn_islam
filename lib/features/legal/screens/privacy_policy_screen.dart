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
                    'Learn Islam — Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Last updated: 25 September 2026'),
                  SizedBox(height: 24),
                  _Section(
                    title: '1. কী তথ্য সংগ্রহ করি',
                    content:
                    'Account তৈরি বা login করলে Firebase '
                        'Authentication-এর মাধ্যমে আপনার নাম, email '
                        'ও account ID ব্যবহার করি। Quiz progress এই '
                        'device-এ সংরক্ষিত হয়। Wallet balance, coin '
                        'purchase history ও premium quiz unlock '
                        'আপনার account-এর অধীনে Firebase Firestore-এ '
                        'সংরক্ষিত হয়।',
                  ),
                  _Section(
                    title: '2. কেন তথ্য ব্যবহার করি',
                    content:
                    'Login চালু রাখা, quiz progress দেখানো, '
                        'coin balance ও purchase history প্রদর্শন, '
                        'এবং কেনা coin দিয়ে premium quiz unlock '
                        'করার জন্য এই তথ্য ব্যবহার করি।',
                  ),
                  _Section(
                    title: '3. Purchase',
                    content:
                    'Android app-এর coin purchase Google Play '
                        'Billing-এর মাধ্যমে হয়। Payment-এর পর '
                        'product ID, purchase ID, প্রাপ্ত coin '
                        'ও সময় purchase history-তে সংরক্ষণ করি। '
                        'আপনার card number আমাদের app সংগ্রহ করে না।',
                  ),
                  _Section(
                    title: '4. সেবা প্রদানকারী',
                    content:
                    'Login ও account data-এর জন্য Google Firebase '
                        'এবং in-app purchase-এর জন্য Google Play '
                        'ব্যবহার করা হয়। এই সেবাগুলো পরিচালনার '
                        'প্রয়োজনে সংশ্লিষ্ট তথ্য প্রক্রিয়াকরণ '
                        'করতে পারে। আমরা ব্যক্তিগত তথ্য বিক্রি করি না।',
                  ),
                  _Section(
                    title: '5. Account ও data মুছে ফেলা',
                    content:
                    'App-এর Profile > Delete Account থেকে '
                        'account মুছতে পারবেন। এতে Firebase account, '
                        'এই account-এর wallet, purchase history, '
                        'premium quiz unlock এবং এই device-এ রাখা '
                        'quiz progress মুছে ফেলার চেষ্টা করা হয়। '
                        'মুছতে সমস্যা হলে support-এ যোগাযোগ করুন। '
                        'Google Play-এর নিজস্ব payment/order record '
                        'আমাদের app থেকে মুছে ফেলা যায় না।',
                  ),
                  _Section(
                    title: '6. যোগাযোগ',
                    content:
                    'Privacy বা account deletion বিষয়ে লিখুন: '
                        'novatechsoft668@outlook.com',
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
      padding: const EdgeInsets.only(bottom: 22),
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
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}