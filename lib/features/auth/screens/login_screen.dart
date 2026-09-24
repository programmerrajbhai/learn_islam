import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../../home/screens/home_screen.dart';
import '../../legal/screens/privacy_policy_screen.dart';
import '../../legal/screens/terms_screen.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _busy = false;
  bool _showPassword = false;
  bool _agreedToTerms = false; // পলিসি চেকবক্স স্টেট

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    final message = error is AuthFailure
        ? error.message
        : 'Login করা যায়নি। আবার চেষ্টা করুন।';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openHome(AppUser user) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(user: user),
      ),
          (_) => false,
    );
  }

  Future<void> _login() async {
    if (_busy || !_formKey.currentState!.validate() || !_agreedToTerms) return;

    setState(() => _busy = true);

    try {
      final user = await authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      _openHome(user);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _googleLogin() async {
    if (_busy || !_agreedToTerms) return; // গুগল লগইনেও চেকবক্স লাগবে

    setState(() => _busy = true);

    try {
      final user = await authService.loginWithGoogle();
      if (!mounted) return;
      _openHome(user);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: colors.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 34,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'আবার স্বাগতম',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Learn Islam: Islam Quiz',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return 'সঠিক email লিখুন';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                        validator: (value) {
                          if ((value?.isEmpty ?? true)) {
                            return 'Password লিখুন';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _busy
                              ? null
                              : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                              const ForgotPasswordScreen(),
                            ),
                          ),
                          child: const Text('Password ভুলে গেছেন?'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Terms and Privacy Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              activeColor: const Color(0xFF145444),
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text('আমি অ্যাপের ', style: TextStyle(fontSize: 13)),
                                InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                                  child: const Text(
                                    'Terms & Conditions',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF145444), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Text(' এবং ', style: TextStyle(fontSize: 13)),
                                InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(fontSize: 13, color: Color(0xFF145444), fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Text(' মেনে নিচ্ছি।', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      FilledButton(
                        onPressed: (_busy || !_agreedToTerms) ? null : _login,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: _busy
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(child: Text('অথবা')),
                      const SizedBox(height: 16),

                      // Google Sign-In Button
                      OutlinedButton.icon(
                        onPressed: (_busy || !_agreedToTerms) ? null : _googleLogin,
                        icon: const Icon(Icons.account_circle_outlined),
                        label: const Text('Google দিয়ে চালিয়ে যান'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text('Account নেই? Register করুন'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const VerifyEmailScreen(),
                          ),
                        ),
                        child: const Text('Verification email আবার পাঠাতে চান?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}