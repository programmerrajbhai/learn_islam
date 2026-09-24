import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
            'Purchase History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: uid == null
              ? const Center(
            child: Text(
              'Login প্রয়োজন',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
              : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: StreamBuilder<QuerySnapshot>(
                // ফায়ারবেস থেকে latest purchase আগে দেখানোর জন্য descending: true
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('purchases')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF2D891)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'হিস্ট্রি লোড করতে সমস্যা হয়েছে।',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final coins = data['coins'] ?? 0;
                      final productId = data['productId'] ?? 'Unknown';
                      final timestamp = data['createdAt'] as Timestamp?;
                      final date = timestamp?.toDate() ?? DateTime.now();

                      return _PurchaseTile(
                        coins: coins,
                        productId: productId,
                        date: date,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 72, color: Color(0xFF4A7266)),
          SizedBox(height: 16),
          Text(
            'কোনো পারচেজ হিস্ট্রি নেই',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'আপনার কেনা কয়েন প্যাকগুলো এখানে দেখা যাবে।',
            style: TextStyle(color: Color(0xFFB9CEC7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({
    required this.coins,
    required this.productId,
    required this.date,
  });

  final int coins;
  final String productId;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateString = '${date.day} ${months[date.month - 1]} ${date.year}';

    // 12-hour format এ সময় কনভার্ট করা
    int hour = date.hour;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minuteString = date.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minuteString $amPm';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B37).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF3B534A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.toll_rounded, color: Color(0xFFF2D891), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+$coins Coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pack: $productId',
                  style: const TextStyle(color: Color(0xFFB9CEC7), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateString,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                timeString,
                style: const TextStyle(color: Color(0xFFB9CEC7), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}