import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/app_background.dart';
import '../../auth/screens/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState
    extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController =
  TextEditingController();

  bool _deleting = false;
  bool _showPassword = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  bool get _usesPassword =>
      _user?.providerData.any(
            (provider) => provider.providerId == 'password',
      ) ??
          false;

  bool get _usesGoogle =>
      _user?.providerData.any(
            (provider) => provider.providerId == 'google.com',
      ) ??
          false;

  Future<void> _reauthenticate(User user) async {
    if (_usesPassword) {
      final email = user.email;

      if (email == null || email.isEmpty) {
        throw StateError('Account email পাওয়া যায়নি।');
      }

      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: _passwordController.text,
        ),
      );
      return;
    }

    if (_usesGoogle) {
      await GoogleSignIn.instance.initialize();

      final googleUser =
      await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw StateError('Google login যাচাই করা যায়নি।');
      }

      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return;
    }

    throw StateError('এই sign-in পদ্ধতি পাওয়া যায়নি।');
  }

  Future<void> _deleteCollection(
      DocumentReference<Map<String, dynamic>> userRef,
      String collectionName,
      ) async {
    final collection = userRef.collection(collectionName);

    while (true) {
      final page = await collection.limit(200).get();

      if (page.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();

      for (final document in page.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    }
  }

  Future<void> _deleteFirestoreData(String uid) async {
    final userRef =
    FirebaseFirestore.instance.collection('users').doc(uid);

    await _deleteCollection(userRef, 'purchases');
    await _deleteCollection(userRef, 'coin_transactions');
    await _deleteCollection(userRef, 'unlocks');

    await userRef.delete();
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Password সঠিক নয়। আবার চেষ্টা করুন।';
        case 'requires-recent-login':
          return 'আবার login করে চেষ্টা করুন।';
        case 'network-request-failed':
          return 'Internet সংযোগ পরীক্ষা করুন।';
      }
    }

    if (error is FirebaseException &&
        error.code == 'permission-denied') {
      return 'Firebase permission না থাকায় data মুছতে পারেনি। '
          'Firestore rules পরীক্ষা করুন।';
    }

    if (error is StateError) {
      return error.message.toString();
    }

    return 'Account মুছতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
  }

  Future<void> _deleteAccount() async {
    if (_deleting) return;

    final user = _user;

    if (user == null) {
      return;
    }

    if (_usesPassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password লিখুন।'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account মুছে ফেলবেন?'),
        content: const Text(
          'আপনার wallet balance, purchase history, '
              'premium quiz unlock এবং quiz progress মুছে যাবে। '
              'এই কাজ ফিরিয়ে আনা যাবে না।',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      // আগে পরিচয় যাচাই, তারপর account-এর data মুছি।
      await _reauthenticate(user);

      final uid = user.uid;
      await _deleteFirestoreData(uid);
      await user.delete();

      final prefs = SharedPreferencesAsync();
      await prefs.remove('free_quiz_attempts_v2_$uid');

      if (_usesGoogle) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {
          // Firebase account ইতিমধ্যে মুছে গেছে।
        }
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
            (_) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      _passwordController.clear();

      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Delete Account'),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_remove_outlined,
                      size: 68,
                      color: Color(0xFFB43D3D),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Account মুছে ফেলুন',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.email ??
                          'কোনো account login করা নেই',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Account মুছলে wallet, purchase history, '
                          'premium unlock ও local quiz progress '
                          'মুছে যাবে।',
                      textAlign: TextAlign.center,
                    ),
                    if (_usesPassword) ...[
                      const SizedBox(height: 24),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password নিশ্চিত করুন',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                  () => _showPassword =
                              !_showPassword,
                            ),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                    ] else if (_usesGoogle) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'পরের ধাপে Google account '
                            'নির্বাচন করতে হবে।',
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: user == null || _deleting
                          ? null
                          : _deleteAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFB43D3D),
                        minimumSize: const Size(0, 54),
                      ),
                      icon: const Icon(
                        Icons.delete_forever_outlined,
                      ),
                      label: Text(
                        _deleting
                            ? 'মুছে ফেলা হচ্ছে...'
                            : 'Account মুছে ফেলুন',
                      ),
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