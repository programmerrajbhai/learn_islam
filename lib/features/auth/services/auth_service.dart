import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

abstract class AuthService {
  Future<AppUser?> currentUser();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

class DemoAuthService implements AuthService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _nameKey = 'demo_account_name';
  static const _emailKey = 'demo_account_email';
  static const _signedInKey = 'demo_signed_in';

  @override
  Future<AppUser?> currentUser() async {
    final signedIn = await _prefs.getBool(_signedInKey) ?? false;
    if (!signedIn) return null;

    final name = await _prefs.getString(_nameKey);
    final email = await _prefs.getString(_emailKey);

    if (name == null || email == null) return null;
    return AppUser(name: name, email: email);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final savedEmail = await _prefs.getString(_emailKey);

    if (savedEmail != null) {
      throw const AuthFailure(
        'এই ডিভাইসে একটি demo account আগে থেকেই আছে। Login করুন।',
      );
    }

    final user = AppUser(
      name: name.trim(),
      email: email.trim().toLowerCase(),
    );

    // Demo-তে password সংরক্ষণ করা হয় না।
    // Firebase যোগ করলে এই method-এ প্রকৃত account তৈরি হবে।
    await _prefs.setString(_nameKey, user.name);
    await _prefs.setString(_emailKey, user.email);
    await _prefs.setBool(_signedInKey, true);

    return user;
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final savedEmail = await _prefs.getString(_emailKey);
    final savedName = await _prefs.getString(_nameKey);

    if (savedEmail == null || savedName == null) {
      throw const AuthFailure('আগে একটি demo account তৈরি করুন।');
    }

    if (email.trim().toLowerCase() != savedEmail) {
      throw const AuthFailure('এই email দিয়ে demo account তৈরি করা হয়নি।');
    }

    // Password ইচ্ছাকৃতভাবে যাচাই করা হচ্ছে না।
    await _prefs.setBool(_signedInKey, true);

    return AppUser(name: savedName, email: savedEmail);
  }

  @override
  Future<void> logout() async {
    await _prefs.setBool(_signedInKey, false);
  }
}

// পরবর্তীতে FirebaseAuthService বসানোর জায়গা এটি।
final AuthService authService = DemoAuthService();