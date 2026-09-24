import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102623), // Bottom Nav Bar-এর হুবহু কালার
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB8D0C6)),
                ),
                const SizedBox(height: 12),

                // Notifications Toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D413B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    activeColor: const Color(0xFFF5D99C),
                    inactiveTrackColor: const Color(0xFF145444),
                    title: const Text('Push Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('নতুন কুইজ ও অফারের আপডেট পান', style: TextStyle(color: Color(0xFFB9DAC9), fontSize: 12)),
                    secondary: const Icon(Icons.notifications_active_rounded, color: Color(0xFFAAD2E8)),
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                ),
                const SizedBox(height: 12),

                // Sound Toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D413B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    activeColor: const Color(0xFFF5D99C),
                    inactiveTrackColor: const Color(0xFF145444),
                    title: const Text('App Sound Effects', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('কুইজের সময় সাউন্ড চালু রাখুন', style: TextStyle(color: Color(0xFFB9DAC9), fontSize: 12)),
                    secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF9EDBBB)),
                    value: _soundEnabled,
                    onChanged: (value) => setState(() => _soundEnabled = value),
                  ),
                ),

                const SizedBox(height: 35),
                const Text(
                  'App Info',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB8D0C6)),
                ),
                const SizedBox(height: 12),

                // Rate Us & Version
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D413B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.star_rounded, color: Color(0xFFF5D99C)),
                        title: const Text('Rate Us on Play Store', style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6D9B82)),
                        onTap: () {
                          // প্লে স্টোর রেটিং এর লজিক
                        },
                      ),
                      const Divider(color: Color(0xFF2C6955), height: 1),
                      const ListTile(
                        leading: Icon(Icons.info_outline_rounded, color: Color(0xFFDAACDC)),
                        title: Text('App Version', style: TextStyle(color: Colors.white)),
                        trailing: Text('v1.0.0', style: TextStyle(color: Color(0xFFB9DAC9), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}