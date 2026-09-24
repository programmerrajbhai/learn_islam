import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../../home/screens/home_screen.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    this.onContinue,
  });

  final VoidCallback? onContinue;

  @override
  State<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;

  Future<void> _check() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final verified = await authService.checkEmailVerified();
      if (!mounted) return;

      if (!verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email এখনো verify হয়নি। Inbox ও Spam folder দেখুন।',
            ),
          ),
        );
        return;
      }

      if (widget.onContinue != null) {
        widget.onContinue!();
        return;
      }

      final user = await authService.currentUser();
      if (!mounted || user == null) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => HomeScreen(user: user),
        ),
            (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is AuthFailure
                ? error.message
                : 'Verification পরীক্ষা করা যায়নি।',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      await authService.sendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email পাঠানো হয়েছে। Inbox দেখুন।',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is AuthFailure
                ? error.message
                : 'Email পাঠানো যায়নি।',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? '';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Email verification'),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 76,
                      color: Color(0xFF16483C),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Email verify করুন',
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
                      email.isEmpty
                          ? 'Verification email দেখতে আপনার account-এ login করুন।'
                          : '$email ঠিকানায় পাঠানো link খুলে তারপর নিচে পরীক্ষা করুন।',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _busy ? null : _check,
                      child: const Text('Verify হয়েছে? পরীক্ষা করুন'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _busy ? null : _resend,
                      child: const Text(
                        'Verification email আবার পাঠান',
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