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

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _deleting = false;
  bool _showPassword = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  bool get _usesPassword {
    return _user?.providerData.any(
          (provider) => provider.providerId == 'password',
    ) ??
        false;
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          return 'Password সঠিক নয়। আবার চেষ্টা করুন।';
        case 'requires-recent-login':
          return 'নিরাপত্তার জন্য আবার login করে চেষ্টা করুন।';
        case 'network-request-failed':
          return 'ইন্টারনেট সংযোগ পরীক্ষা করুন।';
        default:
          return 'Account মুছতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      }
    }
    if (error is GoogleSignInException) {
      return 'Google sign-in সম্পন্ন হয়নি। আবার চেষ্টা করুন।';
    }
    return 'Account মুছতে সমস্যা হয়েছে। আবার চেষ্টা করুন।';
  }

  Future<void> _deleteAccount() async {
    if (_deleting) return;

    final user = _user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আগে account-এ login করুন।'),
        ),
      );
      return;
    }

    if (_usesPassword && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account মুছতে password লিখুন।'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account মুছে ফেলবেন?'),
        content: const Text(
          'আপনার account আর ব্যবহার করা যাবে না। '
              'এই ডিভাইসে রাখা quiz progress-ও মুছে যাবে। '
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
      final hasGoogle = user.providerData.any(
            (provider) => provider.providerId == 'google.com',
      );

      if (_usesPassword) {
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw StateError('Account email পাওয়া যায়নি।');
        }

        final credential = EmailAuthProvider.credential(
          email: email,
          password: _passwordController.text,
        );

        await user.reauthenticateWithCredential(credential);
      } else if (hasGoogle) {
        await GoogleSignIn.instance.initialize();
        final googleUser =
        await GoogleSignIn.instance.authenticate();
        final idToken = googleUser.authentication.idToken;

        if (idToken == null) {
          throw StateError('Google token পাওয়া যায়নি।');
        }

        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      } else {
        throw StateError('Sign-in পদ্ধতি পাওয়া যায়নি।');
      }

      final uid = user.uid;
      await user.delete();

      // Firebase deletion সফল হওয়ার পর এই device-এর local data মুছি।
      final prefs = SharedPreferencesAsync();
      await prefs.remove('free_quiz_attempts_v2_$uid');

      if (hasGoogle) {
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
      if (mounted) setState(() => _deleting = false);
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
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
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
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.email ?? 'কোনো account login করা নেই',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Account মুছলে এই account দিয়ে আর login করা যাবে না। '
                          'এই ডিভাইসে সংরক্ষিত quiz progress মুছে যাবে।',
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
                                  () => _showPassword = !_showPassword,
                            ),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                    ] else if (user != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'পরের ধাপে Google account নির্বাচন করতে হবে।',
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
                      icon: const Icon(Icons.delete_forever_outlined),
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