import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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
  final Set<String> _processingIds = {};

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool isPurchasePending = false;
  String? lastError;

  static const List<CoinPack> packs = [
    CoinPack(productId: 'learn_islam_coins_40', coins: 40, targetUsdCents: 40),
    CoinPack(productId: 'learn_islam_coins_50', coins: 50, targetUsdCents: 50),
    CoinPack(productId: 'learn_islam_coins_100', coins: 100, targetUsdCents: 100),
    CoinPack(productId: 'learn_islam_coins_130', coins: 130, targetUsdCents: 130),
    CoinPack(productId: 'learn_islam_coins_150', coins: 150, targetUsdCents: 150),
    CoinPack(productId: 'learn_islam_coins_200', coins: 200, targetUsdCents: 200),
    CoinPack(productId: 'learn_islam_coins_250', coins: 250, targetUsdCents: 250),
  ];

  String _accountId(String uid) {
    return sha256.convert(utf8.encode(uid)).toString();
  }

  void initialize() {
    if (_subscription != null) return;

    _subscription = _billing.purchaseStream.listen(
          (purchases) {
        unawaited(_handlePurchases(purchases));
      },
      onError: (Object error) {
        lastError = 'Purchase update পাওয়া যায়নি।';
        isPurchasePending = false;
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
      if (!await _billing.isAvailable()) {
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
      debugPrint('Product load error: $error');

      return const CoinStoreData(
        available: false,
        products: {},
        error: 'Coin pack লোড করা যায়নি। আবার চেষ্টা করুন।',
      );
    }
  }

  Future<void> buyCoinPack(ProductDetails product) async {
    if (isPurchasePending) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Coin কিনতে আগে login করুন।');
    }

    if (!packs.any((pack) => pack.productId == product.id)) {
      throw StateError('অজানা coin pack।');
    }

    lastError = null;
    isPurchasePending = true;
    notifyListeners();

    try {
      final PurchaseParam purchaseParam = Platform.isAndroid
          ? GooglePlayPurchaseParam(
        productDetails: product,
        applicationUserName: _accountId(user.uid),
      )
          : PurchaseParam(productDetails: product);

      final started = await _billing.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false,
      );

      if (!started) {
        throw StateError('Google Play purchase শুরু করতে পারেনি।');
      }
    } catch (_) {
      isPurchasePending = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> recoverPendingPurchases() async {
    if (!Platform.isAndroid ||
        FirebaseAuth.instance.currentUser == null) {
      return;
    }

    try {
      final android = _billing.getPlatformAddition<
          InAppPurchaseAndroidPlatformAddition>();

      final response = await android.queryPastPurchases();

      if (response.error != null) {
        throw StateError(response.error!.message);
      }

      await _handlePurchases(response.pastPurchases);
    } catch (error) {
      debugPrint('Purchase recovery error: $error');
      lastError = 'আগের purchase যাচাই করা যায়নি। '
          'Internet চালু রেখে Wallet আবার খুলুন।';
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(
      List<PurchaseDetails> purchases,
      ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          isPurchasePending = true;
          notifyListeners();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _deliverAndFinish(purchase);
          break;

        case PurchaseStatus.error:
          lastError =
              purchase.error?.message ?? 'Purchase ব্যর্থ হয়েছে।';
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

  Future<void> _deliverAndFinish(
      PurchaseDetails purchase,
      ) async {
    final purchaseId = purchase.purchaseID;

    if (purchaseId == null || purchaseId.isEmpty) {
      lastError = 'Purchase ID পাওয়া যায়নি। '
          'আরেকবার কিনবেন না; Support-এ যোগাযোগ করুন।';
      isPurchasePending = false;
      notifyListeners();
      return;
    }

    if (!_processingIds.add(purchaseId)) return;

    isPurchasePending = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw StateError(
          'Purchase-এর account-এ login করে Wallet খুলুন।',
        );
      }

      // অন্য Firebase account-এর purchase এই account-এ credit নয়।
      if (Platform.isAndroid) {
        if (purchase is! GooglePlayPurchaseDetails) {
          throw StateError(
            'Play purchase তথ্য পাওয়া যায়নি। Support-এ যোগাযোগ করুন।',
          );
        }

        final purchaseAccountId =
            purchase.billingClientPurchase.obfuscatedAccountId;

        if (purchaseAccountId == null ||
            purchaseAccountId.isEmpty) {
          throw StateError(
            'পুরোনো purchase-এর account ID নেই। '
                'আরেকবার কিনবেন না; Support-এ যোগাযোগ করুন।',
          );
        }

        if (purchaseAccountId != _accountId(user.uid)) {
          throw StateError(
            'এই purchase অন্য account-এর। '
                'যে account দিয়ে কিনেছিলেন সেটিতে login করুন।',
          );
        }
      }

      final matchingPacks = packs.where(
            (pack) => pack.productId == purchase.productID,
      );

      if (matchingPacks.isEmpty) {
        throw StateError('Purchase-এর coin pack পাওয়া যায়নি।');
      }

      final coins = matchingPacks.first.coins;
      final userRef =
      _firestore.collection('users').doc(user.uid);
      final historyRef =
      userRef.collection('purchases').doc(purchaseId);

      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(historyRef);
        final account = await transaction.get(userRef);

        if (existing.exists) return;

        final rawBalance = account.data()?['coins'];
        final balance =
        rawBalance is num ? rawBalance.toInt() : 0;

        if (balance < 0) {
          throw StateError('Wallet balance invalid।');
        }

        final newBalance = balance + coins;

        transaction.set(
          userRef,
          {
            'coins': newBalance,
            'last_purchase_date':
            FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(historyRef, {
          'coins': coins,
          'productId': purchase.productID,
          'purchaseId': purchaseId,
          'balanceAfter': newBalance,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      if (Platform.isAndroid) {
        final android = _billing.getPlatformAddition<
            InAppPurchaseAndroidPlatformAddition>();

        final result =
        await android.consumePurchase(purchase);

        if (result.responseCode != BillingResponse.ok &&
            result.responseCode !=
                BillingResponse.itemNotOwned) {
          throw StateError(
            'Coin যোগ হয়েছে, কিন্তু Play purchase '
                'সম্পন্ন হয়নি। Wallet আবার খুলুন।',
          );
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _billing.completePurchase(purchase);
      }

      lastError = null;
      isPurchasePending = false;
      notifyListeners();
    } catch (error) {
      debugPrint('Purchase delivery error: $error');

      lastError = error is StateError
          ? error.message.toString()
          : 'Purchase processing শেষ হয়নি। '
          'আরেকবার কিনবেন না; Wallet আবার খুলুন।';

      isPurchasePending = false;
      notifyListeners();
    } finally {
      _processingIds.remove(purchaseId);
    }
  }
}

final BillingService billingService =
    BillingService.instance;