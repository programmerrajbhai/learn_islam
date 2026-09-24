import 'package:in_app_purchase/in_app_purchase.dart';

class CoinPack {
  const CoinPack({
    required this.productId,
    required this.coins,
    required this.targetUsdCents,
  });

  final String productId;
  final int coins;

  // শুধু Play Console-এ দাম সেট করার রেফারেন্স।
  // Wallet-এ দেখানোর দাম ProductDetails.price থেকে নিতে হবে।
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

  // Wallet screen-এর আগের code-এর সঙ্গে compatibility।
  String? get message => error;

  ProductDetails? productFor(CoinPack pack) {
    return products[pack.productId];
  }
}

class BillingService {
  BillingService._();

  static final BillingService instance = BillingService._();

  final InAppPurchase _billing = InAppPurchase.instance;

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
    CoinPack(
      productId: 'learn_islam_coins_300',
      coins: 300,
      targetUsdCents: 300,
    ),
    CoinPack(
      productId: 'learn_islam_coins_350',
      coins: 350,
      targetUsdCents: 350,
    ),
    CoinPack(
      productId: 'learn_islam_coins_400',
      coins: 400,
      targetUsdCents: 400,
    ),
    CoinPack(
      productId: 'learn_islam_coins_450',
      coins: 450,
      targetUsdCents: 450,
    ),
    CoinPack(
      productId: 'learn_islam_coins_500',
      coins: 500,
      targetUsdCents: 500,
    ),
  ];

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
        for (final product in response.productDetails)
          product.id: product,
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
}

// Wallet screen-এর `billingService.loadStore()`-এর জন্য।
final BillingService billingService = BillingService.instance;