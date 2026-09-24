import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinPack {
  const CoinPack({
    required this.productId,
    required this.coins,
    required this.targetUsdCents,
  });

  final String productId;
  final int coins;
  final int targetUsdCents;
}

class CoinStoreData {
  const CoinStoreData({
    required this.available,
    required this.products,
    this.error,
    this.notFoundIds = const [],
  });

  final bool available;
  final Map<String, ProductDetails> products;
  final String? error;
  final List<String> notFoundIds;

  bool get isAvailable => available;
  String? get message => error;
}

class BillingService extends ChangeNotifier {
  BillingService._();
  static final BillingService instance = BillingService._();

  final InAppPurchase _billing = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool isPurchasePending = false;

  // আপনার দেওয়া ১২টি প্রোডাক্টের সম্পূর্ণ লিস্ট
  static const List<CoinPack> packs = [
    CoinPack(productId: 'learn_islam_coins_40', coins: 40, targetUsdCents: 40),
    CoinPack(productId: 'learn_islam_coins_50', coins: 50, targetUsdCents: 50),
    CoinPack(productId: 'learn_islam_coins_100', coins: 100, targetUsdCents: 100),
    CoinPack(productId: 'learn_islam_coins_130', coins: 130, targetUsdCents: 130),
    CoinPack(productId: 'learn_islam_coins_150', coins: 150, targetUsdCents: 150),
    CoinPack(productId: 'learn_islam_coins_200', coins: 200, targetUsdCents: 200),
    CoinPack(productId: 'learn_islam_coins_250', coins: 250, targetUsdCents: 250),
    CoinPack(productId: 'learn_islam_coins_300', coins: 300, targetUsdCents: 300),
    CoinPack(productId: 'learn_islam_coins_350', coins: 350, targetUsdCents: 350),
    CoinPack(productId: 'learn_islam_coins_400', coins: 400, targetUsdCents: 400),
    CoinPack(productId: 'learn_islam_coins_450', coins: 450, targetUsdCents: 450),
    CoinPack(productId: 'learn_islam_coins_500', coins: 500, targetUsdCents: 500),
  ];

  void initialize() {
    final purchaseUpdated = _billing.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      debugPrint("Purchase Stream Error: $error");
    });
  }

  void disposeService() {
    _subscription?.cancel();
  }

  Future<CoinStoreData> loadStore() async {
    try {
      final available = await _billing.isAvailable();
      if (!available) {
        return const CoinStoreData(
          available: false,
          products: {},
          error: 'Google Play Store এখন পাওয়া যাচ্ছে না।',
        );
      }

      final productIds = packs.map((pack) => pack.productId).toSet();
      final response = await _billing.queryProductDetails(productIds);

      final products = <String, ProductDetails>{
        for (final product in response.productDetails) product.id: product,
      };

      return CoinStoreData(
        available: true,
        products: products,
        error: response.error?.message,
        notFoundIds: response.notFoundIDs,
      );
    } catch (_) {
      return const CoinStoreData(
        available: false,
        products: {},
        error: 'Coin pack লোড করা যায়নি। আবার চেষ্টা করুন।',
      );
    }
  }

  Future<void> buyCoinPack(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    // Auto consume true করে দিলাম যাতে ইউজার বারবার কয়েন কিনতে পারে
    await _billing.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isPurchasePending = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          isPurchasePending = false;
          notifyListeners();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {

          // পেমেন্ট সফল হলে ফায়ারবেসে কয়েন অ্যাড হবে
          await _deliverCoinsToUser(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _billing.completePurchase(purchaseDetails);
        }

        isPurchasePending = false;
        notifyListeners();
      }
    }
  }

// Firebase Ledger: ইউজারের অ্যাকাউন্টে কয়েন যোগ করা এবং হিস্ট্রি রাখা
  Future<void> _deliverCoinsToUser(PurchaseDetails purchaseDetails) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final pack = packs.firstWhere((p) => p.productId == purchaseDetails.productID);
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // ১. ইউজারের মূল ব্যালেন্স আপডেট করা
      await userRef.set({
        'coins': FieldValue.increment(pack.coins),
        'last_purchase_date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ২. পারচেজ হিস্ট্রি (Ledger) সেভ করা
      // purchaseID দিয়ে ডকুমেন্ট সেভ করলে একই পেমেন্ট দুবার অ্যাড হবে না
      final historyRef = userRef.collection('purchases').doc(purchaseDetails.purchaseID);
      await historyRef.set({
        'coins': pack.coins,
        'productId': pack.productId,
        'purchaseId': purchaseDetails.purchaseID,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint("Coin delivery failed: $e");
    }
  }


}

final BillingService billingService = BillingService.instance;