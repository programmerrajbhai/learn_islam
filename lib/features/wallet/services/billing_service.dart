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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Set<String> _processingPurchases = {};

  bool isPurchasePending = false;
  String? lastError;

  static const List<CoinPack> packs = [
    CoinPack(
      productId: 'learn_islam_coins_40',
      coins: 40,
      targetUsdCents: 40,
    ),
    CoinPack(
      productId: 'learn_islam_coins_50',
      coins: 50,
      targetUsdCents: 50,
    ),
    CoinPack(
      productId: 'learn_islam_coins_100',
      coins: 100,
      targetUsdCents: 100,
    ),
    CoinPack(
      productId: 'learn_islam_coins_130',
      coins: 130,
      targetUsdCents: 130,
    ),
    CoinPack(
      productId: 'learn_islam_coins_150',
      coins: 150,
      targetUsdCents: 150,
    ),
    CoinPack(
      productId: 'learn_islam_coins_200',
      coins: 200,
      targetUsdCents: 200,
    ),
    CoinPack(
      productId: 'learn_islam_coins_250',
      coins: 250,
      targetUsdCents: 250,
    ),
  ];

  void initialize() {
    if (_subscription != null) return;

    _subscription = _billing.purchaseStream.listen(
          (purchases) {
        unawaited(_handlePurchases(purchases));
      },
      onError: (Object error) {
        lastError = 'Purchase update পাওয়া যায়নি।';
        debugPrint('Purchase stream error: $error');
        notifyListeners();
      },
    );
  }

  void disposeService() {
    _subscription?.cancel();
    _subscription = null;
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

      final response = await _billing.queryProductDetails(
        packs.map((pack) => pack.productId).toSet(),
      );

      return CoinStoreData(
        available: true,
        products: {
          for (final product in response.productDetails)
            product.id: product,
        },
        error: response.error?.message,
        notFoundIds: response.notFoundIDs,
      );
    } catch (error) {
      debugPrint('Product load failed: $error');

      return const CoinStoreData(
        available: false,
        products: {},
        error: 'Coin pack লোড করা যায়নি। আবার চেষ্টা করুন।',
      );
    }
  }

  Future<void> buyCoinPack(ProductDetails productDetails) async {
    if (isPurchasePending) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Coin কিনতে আগে login করুন।');
    }

    if (!packs.any((pack) => pack.productId == productDetails.id)) {
      throw StateError('অজানা coin pack।');
    }

    lastError = null;
    isPurchasePending = true;
    notifyListeners();

    try {
      final started = await _billing.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
        autoConsume: true,
      );

      if (!started) {
        isPurchasePending = false;
        notifyListeners();
        throw StateError('Google Play purchase শুরু করতে পারেনি।');
      }
    } catch (_) {
      isPurchasePending = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasePending = true;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchase);
          break;

        case PurchaseStatus.error:
          lastError = purchase.error?.message ?? 'Purchase ব্যর্থ হয়েছে।';
          isPurchasePending = false;
          notifyListeners();
          break;

        case PurchaseStatus.canceled:
          isPurchasePending = false;
          notifyListeners();
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchase,
      ) async {
    final purchaseId = purchase.purchaseID;

    // নির্ভরযোগ্য ID ছাড়া coin দেওয়া হলে একই purchase শনাক্ত করা যায় না।
    if (purchaseId == null || purchaseId.isEmpty) {
      lastError = 'Purchase ID পাওয়া যায়নি। Support-এ যোগাযোগ করুন।';
      isPurchasePending = false;
      notifyListeners();
      return;
    }

    if (!_processingPurchases.add(purchaseId)) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError('Purchase সম্পন্ন হয়েছে; account-এ login করুন।');
      }

      final pack = packs.where(
            (item) => item.productId == purchase.productID,
      );

      if (pack.isEmpty) {
        throw StateError('Purchase-এর coin pack পাওয়া যায়নি।');
      }

      final coins = pack.first.coins;
      final userRef = _firestore.collection('users').doc(user.uid);
      final historyRef = userRef.collection('purchases').doc(purchaseId);

      await _firestore.runTransaction((transaction) async {
        // Transaction-এর সব read আগে, তারপর write।
        final history = await transaction.get(historyRef);
        final account = await transaction.get(userRef);

        if (history.exists) {
          return; // আগেই coin দেওয়া হয়েছে।
        }

        final data = account.data();
        final rawBalance = data?['coins'];
        final oldBalance = rawBalance is num ? rawBalance.toInt() : 0;

        if (oldBalance < 0) {
          throw StateError('Wallet balance invalid।');
        }

        final newBalance = oldBalance + coins;

        transaction.set(
          userRef,
          {
            'coins': newBalance,
            'last_purchase_date': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(historyRef, {
          'coins': coins,
          'productId': purchase.productID,
          'purchaseId': purchaseId,
          'createdAt': FieldValue.serverTimestamp(),
          'balanceAfter': newBalance,
        });
      });

      // Coin save সফল হওয়ার পরেই purchase complete করি।
      if (purchase.pendingCompletePurchase) {
        await _billing.completePurchase(purchase);
      }

      lastError = null;
      isPurchasePending = false;
      notifyListeners();
    } catch (error) {
      debugPrint('Coin delivery failed: $error');
      lastError = 'Payment হয়েছে, কিন্তু coin save হয়নি। '
          'আরেকবার কিনবেন না; Support-এ যোগাযোগ করুন।';
      isPurchasePending = false;
      notifyListeners();
    } finally {
      _processingPurchases.remove(purchaseId);
    }
  }
}

final BillingService billingService = BillingService.instance;