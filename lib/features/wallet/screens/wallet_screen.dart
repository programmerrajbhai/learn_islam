import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../services/billing_service.dart';

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
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20, 25, 20, 32,
                  ),
                  children: [
                    const Text(
                      'Premium Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Coins দিয়ে premium quiz unlock করুন',
                      style: TextStyle(
                        color: Color(0xFFB9CEC7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 23),
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
                    const SizedBox(height: 5),
                    const Text(
                      'দাম Google Play থেকে দেখানো হবে',
                      style: TextStyle(
                        color: Color(0xFFB9CEC7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 17),
                    FutureBuilder<CoinStoreData>(
                      future: _store,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(35),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF2D891),
                              ),
                            ),
                          );
                        }

                        final store = snapshot.data!;

                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            if (store.message != null) ...[
                              _InfoCard(text: store.message!),
                              const SizedBox(height: 15),
                            ],
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth =
                                    (constraints.maxWidth - 12) / 2;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    for (final pack
                                    in BillingService.packs)
                                      SizedBox(
                                        width: cardWidth,
                                        child: _PackCard(
                                          coins: pack.coins,
                                          price: store
                                              .products[
                                          pack.productId]
                                              ?.price ??
                                              'Unavailable',
                                          available: store.products
                                              .containsKey(
                                            pack.productId,
                                          ),
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
                    const SizedBox(height: 20),
                    const _InfoCard(
                      text:
                      'Coin purchase চালু হওয়ার আগে payment verification '
                          'ও balance restore যুক্ত করা হবে।',
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
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF285D50),
            Color(0xFF173B35),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT BALANCE',
                  style: TextStyle(
                    color: Color(0xFFB9D4C9),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '—',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 43,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Balance service যুক্ত হচ্ছে',
                  style: TextStyle(
                    color: Color(0xFFD5E6DF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
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
    required this.price,
    required this.available,
  });

  final int coins;
  final String price;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37)
            .withValues(alpha: 0.85),
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
            price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: available
                  ? const Color(0xFFF2D891)
                  : const Color(0xFFB9CEC7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // Verification API ও balance ledger প্রস্তুত না
              // হওয়া পর্যন্ত payment শুরু করা যাবে না।
              onPressed: null,
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
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFF2D891),
            size: 21,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD5E6DF),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}