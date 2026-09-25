import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizUnlockService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('আগে login করুন।');
    }
    return uid;
  }

  Stream<bool> watchUnlocked(String quizId) {
    final uid = _uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('unlocks')
        .doc(quizId)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> unlock({
    required String quizId,
    required int coinCost,
  }) async {
    if (!{
      'quran_premium_01',
      'ibadah_premium_01',
    }.contains(quizId)) {
      throw StateError('এই premium quiz পাওয়া যায়নি।');
    }

    // বর্তমানে দুই quiz-এর server catalog price ২০ coin।
    // শুধু UI থেকে পাঠানো দাম বিশ্বাস করছি না।
    if (coinCost != 20) {
      throw StateError('Quiz-এর coin মূল্য সঠিক নয়।');
    }

    final uid = _uid;
    final userRef = _db.collection('users').doc(uid);
    final unlockRef =
    userRef.collection('unlocks').doc(quizId);
    final transactionRef =
    userRef.collection('coin_transactions').doc('unlock_$quizId');

    await _db.runTransaction((transaction) async {
      // সব read আগে করতে হবে।
      final unlockSnapshot = await transaction.get(unlockRef);
      final userSnapshot = await transaction.get(userRef);

      if (unlockSnapshot.exists) {
        return; // আগে unlock হয়েছে; আর coin কাটবে না।
      }

      final value = userSnapshot.data()?['coins'];
      final balance = value is num ? value.toInt() : 0;

      if (balance < coinCost) {
        throw StateError('পর্যাপ্ত coin নেই।');
      }

      final remaining = balance - coinCost;

      transaction.set(
        userRef,
        {'coins': remaining},
        SetOptions(merge: true),
      );

      transaction.set(unlockRef, {
        'quizId': quizId,
        'coinCost': coinCost,
        'unlockedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(transactionRef, {
        'type': 'quiz_unlock',
        'quizId': quizId,
        'amount': -coinCost,
        'balanceAfter': remaining,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

final QuizUnlockService quizUnlockService = QuizUnlockService();