import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../quiz/screens/topics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  int _progressRevision = 0;
  bool _signingOut = false;

  Future<void> _logout() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);

    try {
      await authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout করা যায়নি। আবার চেষ্টা করুন।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  width: constraints.maxWidth > 700
                      ? 700
                      : constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _HomeDashboard(
                        user: widget.user,
                        onOpenTopics: () {
                          setState(() => _selectedTab = 1);
                        },
                      ),
                      TopicsScreen(
                        onQuizFinished: () {
                          setState(() => _progressRevision++);
                        },
                      ),
                      ProgressScreen(revision: _progressRevision),
                      ProfileScreen(
                        user: widget.user,
                        signingOut: _signingOut,
                        onLogout: _logout,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
          },
          backgroundColor: const Color(0xFFF9F8F2),
          indicatorColor: const Color(0xFFDDEDE2),
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Topics',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.user, required this.onOpenTopics});

  final AppUser user;
  final VoidCallback onOpenTopics;

  @override
  Widget build(BuildContext context) {
    final name = user.name.trim();
    final firstName = name.isEmpty ? 'শিক্ষার্থী' : name.split(' ').first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 35),
      children: [
        const Row(
          children: [
            _BrandIcon(),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learn Islam',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF173A33),
                  ),
                ),
                Text(
                  'Islam Quiz',
                  style: TextStyle(color: Color(0xFF6C8277), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 34),
        Text(
          'আসসালামু আলাইকুম, $firstName',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF173A33),
            fontSize: 27,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'আজ নতুন কিছু জানার সুন্দর একটি দিন।',
          style: TextStyle(color: Color(0xFF6C8277), fontSize: 14),
        ),
        const SizedBox(height: 25),
        _HeroCard(onOpenTopics: onOpenTopics),
        const SizedBox(height: 32),
        Row(
          children: [
            const Expanded(
              child: Text(
                'শেখার বিষয়',
                style: TextStyle(
                  color: Color(0xFF173A33),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: onOpenTopics, child: const Text('সব দেখুন')),
          ],
        ),
        const Text(
          'মৌলিক বিষয়গুলো দিয়ে শুরু করুন',
          style: TextStyle(color: Color(0xFF718278)),
        ),
        const SizedBox(height: 16),
        _PreviewCard(
          title: 'ইসলামের পরিচিতি',
          subtitle: 'মৌলিক ধারণা ও পরিচয়',
          icon: Icons.menu_book_rounded,
          iconColor: const Color(0xFF176A55),
          iconBackground: const Color(0xFFE0F0E6),
          onTap: onOpenTopics,
        ),
        const SizedBox(height: 11),
        _PreviewCard(
          title: 'ইবাদত',
          subtitle: 'দৈনন্দিন অনুশীলন ও জ্ঞান',
          icon: Icons.nights_stay_rounded,
          iconColor: const Color(0xFF876437),
          iconBackground: const Color(0xFFF7ECD5),
          onTap: onOpenTopics,
        ),
        const SizedBox(height: 11),
        _PreviewCard(
          title: 'আখলাক',
          subtitle: 'আচরণ ও সুন্দর অভ্যাস',
          icon: Icons.favorite_outline_rounded,
          iconColor: const Color(0xFF755E96),
          iconBackground: const Color(0xFFEEE8F7),
          onTap: onOpenTopics,
        ),
        const SizedBox(height: 28),
        const _LearningNote(),
      ],
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF16483C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.menu_book_rounded, color: Color(0xFFE9D89E)),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onOpenTopics});

  final VoidCallback onOpenTopics;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF205B4B), Color(0xFF103B34)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16483C).withValues(alpha: 0.17),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -22,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 175,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEARN • PRACTICE • GROW',
                  style: TextStyle(
                    color: Color(0xFFF0DAA0),
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'জানুন, ভাবুন,\nনিজেকে যাচাই করুন',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'বাংলায় সহজ প্রশ্নের মাধ্যমে ইসলামের মৌলিক বিষয়গুলো অনুশীলন করুন।',
                  style: TextStyle(
                    color: Color(0xFFE0EBE6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: onOpenTopics,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAD9A7),
                    foregroundColor: const Color(0xFF173A33),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('বিষয় দেখুন'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF173A33),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF708178),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFF859A8D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningNote extends StatelessWidget {
  const _LearningNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1A624C)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'প্রশ্নের সঙ্গে ব্যাখ্যা ও উৎস পড়ার সুবিধা যুক্ত হবে।',
              style: TextStyle(color: Color(0xFF355B49), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
