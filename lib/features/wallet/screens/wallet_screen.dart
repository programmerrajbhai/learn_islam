import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/widgets/app_background.dart';
import '../services/billing_service.dart';
import 'purchase_history_screen.dart'; // হিস্ট্রি স্ক্রিনের ইমপোর্ট

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<CoinStoreData> _store;

  @override
  void initState() {
    super.initState();
    _store = billingService.loadStore();
    billingService.addListener(_onBillingStateChanged);
  }

  @override
  void dispose() {
    billingService.removeListener(_onBillingStateChanged);
    super.dispose();
  }

  void _onBillingStateChanged() {
    if (mounted) setState(() {});
  }

  void _reload() {
    setState(() {
      _store = billingService.loadStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      dark: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Premium Wallet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            // হিস্ট্রি স্ক্রিনে যাওয়ার বাটন
            IconButton(
              icon: const Icon(Icons.history_rounded, color: Colors.white),
              tooltip: 'Purchase History',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PurchaseHistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  children: [
                    const Text(
                      'Coins দিয়ে premium quiz unlock করুন',
                      style: TextStyle(color: Color(0xFFB9CEC7), fontSize: 13),
                    ),
                    const SizedBox(height: 23),

                    // ব্যালেন্স কার্ড
                    const _BalanceCard(),

                    const SizedBox(height: 30),
                    const Text(
                      'Coin packs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 17),

                    if (billingService.isPurchasePending)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: _InfoCard(text: 'পেমেন্ট প্রসেস হচ্ছে, অনুগ্রহ করে অপেক্ষা করুন...'),
                      ),

                    FutureBuilder<CoinStoreData>(
                      future: _store,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(35),
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFFF2D891)),
                            ),
                          );
                        }

                        final store = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (store.message != null) ...[
                              _InfoCard(text: store.message!),
                              const SizedBox(height: 15),
                            ],
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth = (constraints.maxWidth - 12) / 2;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final pack in BillingService.packs)
                                      if (store.products.containsKey(pack.productId))
                                        SizedBox(
                                          width: cardWidth,
                                          child: _PackCard(
                                            coins: pack.coins,
                                            productDetails: store.products[pack.productId]!,
                                            isPending: billingService.isPurchasePending,
                                          ),
                                        ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF285D50), Color(0xFF173B35)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT BALANCE',
                  style: TextStyle(
                    color: Color(0xFFB9D4C9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                if (uid != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                    builder: (context, snapshot) {
                      // স্পিনার সম্পূর্ণ রিমুভ করা হয়েছে। এরর বা ওয়েটিং স্টেটে সরাসরি 0 দেখাবে।
                      if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          '0',
                          style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w800),
                        );
                      }

                      int currentCoins = 0;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        currentCoins = data?['coins'] ?? 0;
                      }

                      return Text(
                        currentCoins.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 43,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  )
                else
                  const Text('0', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w800)),

                const SizedBox(height: 3),
                const Text(
                  'Premium Quiz খেলতে ব্যবহার করুন',
                  style: TextStyle(color: Color(0xFFD5E6DF), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 61,
            color: Color(0xFFF2D891),
          ),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.coins,
    required this.productDetails,
    required this.isPending,
  });

  final int coins;
  final ProductDetails productDetails;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF3B534A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.toll_rounded,
              color: Color(0xFFF2D891),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$coins Coins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            productDetails.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFF2D891), fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isPending ? null : () => billingService.buyCoinPack(productDetails),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 45),
                backgroundColor: const Color(0xFFF2D891),
                foregroundColor: const Color(0xFF173B35),
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFF2D891), size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFFD5E6DF), fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}