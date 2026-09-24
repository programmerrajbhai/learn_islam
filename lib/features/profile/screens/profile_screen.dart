import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';
import '../../legal/screens/delete_account_screen.dart';
import '../../legal/screens/privacy_policy_screen.dart';
import '../../legal/screens/terms_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.signingOut,
  });

  final AppUser user;
  final VoidCallback onLogout;
  final bool signingOut;

  @override
  Widget build(BuildContext context) {
    // Container-এর মাধ্যমে পুরো স্ক্রিনকে Bottom Nav Bar-এর হুবহু কালার দেওয়া হলো
    return Container(
      color: const Color(0xFF102623),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 36),
        children: [
          const Text(
            'আপনার প্রোফাইল',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 25),

          // Profile Info Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C6955), Color(0xFF184438)],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF6D9B82)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0xFF3F8068),
                  child: Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: Color(0xFFF5D99C),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'শিক্ষার্থী' : user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD0E4D9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // Menu Section: Account & Settings
          const Text(
            'অ্যাকাউন্ট ও সেটিংস',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8D0C6),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.edit_note_rounded,
            title: 'Edit Profile',
            subtitle: 'নাম পরিবর্তন করুন',
            iconColor: const Color(0xFF9EDBBB),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'অ্যাপের সেটিংস কাস্টমাইজ করুন',
            iconColor: const Color(0xFFAAD2E8),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Premium Wallet',
            subtitle: 'কয়েন কিনুন এবং হিস্ট্রি দেখুন',
            iconColor: const Color(0xFFF5D99C),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
          ),

          const SizedBox(height: 30),

          // Menu Section: About & Legal
          const Text(
            'আইনি তথ্য ও পলিসি',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8D0C6),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            iconColor: const Color(0xFFDAACDC),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            iconColor: const Color(0xFFDAACDC),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),

          const SizedBox(height: 35),

          // Menu Section: Danger Zone
          const Text(
            'ডেঞ্জার জোন',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE57373),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout_rounded,
            title: signingOut ? 'Logout হচ্ছে...' : 'Logout',
            iconColor: const Color(0xFFE57373),
            onTap: signingOut ? null : onLogout,
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.person_remove_outlined,
            title: 'Delete Account',
            iconColor: const Color(0xFFE57373),
            onTap: signingOut
                ? null
                : () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DeleteAccountScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Menu Tile Widget
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1D413B),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB9DAC9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6D9B82)),
            ],
          ),
        ),
      ),
    );
  }
}