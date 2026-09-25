import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/widgets/app_background.dart';
import '../services/billing_service.dart';
import 'purchase_history_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<CoinStoreData> _storeFuture;
  String? _shownError;

  @override
  void initState() {
    super.initState();

    billingService.addListener(_onBillingChanged);
    _storeFuture = billingService.loadStore();

    // Firestore write ব্যর্থ হওয়া unconsumed purchase retry করবে।
    unawaited(billingService.recoverPendingPurchases());
  }

  @override
  void dispose() {
    billingService.removeListener(_onBillingChanged);
    super.dispose();
  }

  void _onBillingChanged() {
    if (!mounted) return;

    setState(() {});

    final error = billingService.lastError;

    if (error == null) {
      _shownError = null;
      return;
    }

    if (error == _shownError) return;
    _shownError = error;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _storeFuture = billingService.loadStore();
    });

    await Future.wait([
      _storeFuture,
      billingService.recoverPendingPurchases(),
    ]);
  }

  Future<void> _buy(ProductDetails product) async {
    try {
      await billingService.buyCoinPack(product);
    } catch (error) {
      if (!mounted) return;

      final message = error is StateError
          ? error.message.toString()
          : 'Purchase শুরু করা যায়নি। আবার চেষ্টা করুন।';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return AppBackground(
      dark: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Premium Wallet'),
          actions: [
            IconButton(
              tooltip: 'Purchase History',
              icon: const Icon(Icons.history_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PurchaseHistoryScreen(),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    32,
                  ),
                  children: [
                    const Text(
                      'Coins দিয়ে premium quiz unlock করুন',
                      style: TextStyle(
                        color: Color(0xFFB9CEC7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _BalanceCard(uid: uid),
                    const SizedBox(height: 28),
                    const Text(
                      'Coin packs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (billingService.isPurchasePending) ...[
                      const _InfoCard(
                        text: 'Purchase processing হচ্ছে। '
                            'অনুগ্রহ করে অপেক্ষা করুন।',
                      ),
                      const SizedBox(height: 14),
                    ],
                    FutureBuilder<CoinStoreData>(
                      future: _storeFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const _InfoCard(
                            text: 'Coin pack লোড করা যায়নি। '
                                'নিচে টেনে আবার চেষ্টা করুন।',
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF2D891),
                              ),
                            ),
                          );
                        }

                        final store = snapshot.data!;

                        if (!store.available) {
                          return _InfoCard(
                            text: store.message ??
                                'Google Play Store পাওয়া যাচ্ছে না।',
                          );
                        }

                        final visiblePacks =
                        BillingService.packs.where(
                              (pack) => store.products
                              .containsKey(pack.productId),
                        ).toList();

                        if (visiblePacks.isEmpty) {
                          return const _InfoCard(
                            text: 'কোনো coin pack পাওয়া যায়নি। '
                                'Google Play থেকে app install করুন '
                                'এবং Play Console-এ products active '
                                'আছে কি না দেখুন।',
                          );
                        }

                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            if (store.message != null) ...[
                              _InfoCard(text: store.message!),
                              const SizedBox(height: 14),
                            ],
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final columns =
                                constraints.maxWidth < 360
                                    ? 1
                                    : 2;

                                final cardWidth = columns == 1
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth -
                                    12) /
                                    2;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final pack
                                    in visiblePacks)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _PackCard(
                                          coins: pack.coins,
                                          product: store.products[
                                          pack.productId]!,
                                          pending: billingService
                                              .isPurchasePending,
                                          onBuy: _buy,
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
  const _BalanceCard({required this.uid});

  final String? uid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF285D50),
            Color(0xFF173B35),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
                if (uid == null)
                  const _BalanceText('—')
                else
                  StreamBuilder<
                      DocumentSnapshot<
                          Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Balance লোড করা যায়নি',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const _BalanceText('—');
                      }

                      final raw =
                      snapshot.data!.data()?['coins'];
                      final balance =
                      raw is num ? raw.toInt() : 0;

                      return _BalanceText('$balance');
                    },
                  ),
                const SizedBox(height: 4),
                const Text(
                  'Premium quiz খেলতে ব্যবহার করুন',
                  style: TextStyle(
                    color: Color(0xFFD5E6DF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 58,
            color: Color(0xFFF2D891),
          ),
        ],
      ),
    );
  }
}

class _BalanceText extends StatelessWidget {
  const _BalanceText(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 43,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.coins,
    required this.product,
    required this.pending,
    required this.onBuy,
  });

  final int coins;
  final ProductDetails product;
  final bool pending;
  final Future<void> Function(ProductDetails) onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF3B534A),
            child: Icon(
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
            product.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF2D891),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
              pending ? null : () => onBuy(product),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 45),
                backgroundColor:
                const Color(0xFFF2D891),
                foregroundColor:
                const Color(0xFF173B35),
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
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFF2D891),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD5E6DF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}