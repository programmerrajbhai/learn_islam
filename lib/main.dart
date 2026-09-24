import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'features/wallet/services/billing_service.dart'; // এই লাইনটি যোগ করুন

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // পেমেন্ট ব্যাকগ্রাউন্ড লিসেনার চালু করা
  billingService.initialize();

  runApp(const LearnIslamApp());
}