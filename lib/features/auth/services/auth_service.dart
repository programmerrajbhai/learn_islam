import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
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

  Future<AppUser> loginWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendVerificationEmail();

  Future<bool> checkEmailVerified();

  Future<void> logout();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  Future<void>? _googleInitialization;

  Future<void> _initializeGoogle() {
    return _googleInitialization ??= _google.initialize();
  }

  AppUser _toAppUser(User user) {
    final email = user.email ?? '';
    final name = user.displayName?.trim();

    return AppUser(
      uid: user.uid,
      name: name != null && name.isNotEmpty
          ? name
          : (email.isNotEmpty ? email.split('@').first : 'শিক্ষার্থী'),
      email: email,
    );
  }

  AuthFailure _readableError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return const AuthFailure('এই email দিয়ে account আগে থেকেই আছে।');
      case 'invalid-email':
        return const AuthFailure('সঠিক email লিখুন।');
      case 'weak-password':
        return const AuthFailure('আরও শক্তিশালী password ব্যবহার করুন।');
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return const AuthFailure('Email অথবা password সঠিক নয়।');
      case 'user-disabled':
        return const AuthFailure('এই account ব্যবহার করা যাচ্ছে না।');
      case 'too-many-requests':
        return const AuthFailure(
          'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।',
        );
      case 'network-request-failed':
        return const AuthFailure('ইন্টারনেট সংযোগ পরীক্ষা করুন।');
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'এই email-এ অন্য sign-in পদ্ধতি ব্যবহার করা হয়েছে।',
        );
      default:
        return const AuthFailure(
          'কাজটি সম্পন্ন হয়নি। কিছুক্ষণ পরে আবার চেষ্টা করুন।',
        );
    }
  }

  @override
  Future<AppUser?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      await user.reload();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'user-disabled') {
        await _auth.signOut();
        return null;
      }
      // Offline থাকলেও আগে থেকে সংরক্ষিত Firebase session চালু থাকবে।
    }

    final refreshedUser = _auth.currentUser;
    return refreshedUser == null ? null : _toAppUser(refreshedUser);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw const AuthFailure('Account তৈরি করা যায়নি। আবার চেষ্টা করুন।');
      }

      await user.updateDisplayName(name.trim());
      await user.reload();

      return _toAppUser(_auth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }



  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user;
      if (user == null) {
        throw const AuthFailure('Login করা যায়নি। আবার চেষ্টা করুন।');
      }

      await user.reload();
      return _toAppUser(_auth.currentUser ?? user);
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    try {
      await _initializeGoogle();

      final googleUser = await _google.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthFailure(
          'Google sign-in configuration পাওয়া যায়নি।',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);

      final user = result.user;
      if (user == null) {
        throw const AuthFailure('Google দিয়ে login করা যায়নি।');
      }

      return _toAppUser(user);
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Google sign-in বাতিল করা হয়েছে।');
      }
      throw const AuthFailure(
        'Google sign-in করা যায়নি। Firebase Google provider ও SHA keys পরীক্ষা করুন।',
      );
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure('আবার login করুন।');
    }

    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure('আবার login করুন।');
    }

    try {
      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _initializeGoogle();
      await _google.signOut();
    } on FirebaseAuthException catch (error) {
      throw _readableError(error);
    }
  }
}

final AuthService authService = FirebaseAuthService();