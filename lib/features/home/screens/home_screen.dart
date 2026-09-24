import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_background.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../progress/services/quiz_progress_service.dart';
import '../../quiz/data/quiz_repository.dart';
import '../../quiz/models/quiz_models.dart';
import '../../quiz/screens/quiz_details_screen.dart';
import '../../quiz/screens/quiz_list_screen.dart';
import '../../quiz/screens/topics_screen.dart';
import '../../wallet/screens/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  int _progressRevision = 0;
  bool _signingOut = false;

  void _quizFinished() {
    if (!mounted) return;
    setState(() => _progressRevision++);
  }

  void _openProgress() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('আপনার অগ্রগতি'),
              backgroundColor: Colors.transparent,
            ),
            body: ProgressScreen(
              revision: _progressRevision,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);

    try {
      await authService.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        ),
            (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout করা যায়নি। আবার চেষ্টা করুন।'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkTab = _selectedTab == 0 ||
        _selectedTab == 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: darkTab
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: AppBackground(
        dark: darkTab,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(maxWidth: 720),
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _HomeDashboard(
                      user: widget.user,
                      revision: _progressRevision,
                      onOpenTopics: () => setState(
                            () => _selectedTab = 1,
                      ),
                      onOpenWallet: () => setState(
                            () => _selectedTab = 2,
                      ),
                      onOpenProgress: _openProgress,
                      onQuizFinished: _quizFinished,
                    ),
                    TopicsScreen(
                      onQuizFinished: _quizFinished,
                    ),
                    const WalletScreen(),
                    ProfileScreen(
                      user: widget.user,
                      signingOut: _signingOut,
                      onLogout: _logout,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor:
              const Color(0xFF102623),
              indicatorColor:
              const Color(0xFF275549),
              labelTextStyle:
              WidgetStateProperty.resolveWith(
                    (states) => TextStyle(
                  color: states.contains(
                    WidgetState.selected,
                  )
                      ? const Color(0xFFF5D99C)
                      : const Color(0xFFB7CBC2),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme:
              WidgetStateProperty.resolveWith(
                    (states) => IconThemeData(
                  color: states.contains(
                    WidgetState.selected,
                  )
                      ? const Color(0xFFF5D99C)
                      : const Color(0xFFB7CBC2),
                  size: 24,
                ),
              ),
            ),
            child: NavigationBar(
              height: 72,
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) {
                setState(() => _selectedTab = index);
              },
              labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                  Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon:
                  Icon(Icons.grid_view_outlined),
                  selectedIcon:
                  Icon(Icons.grid_view_rounded),
                  label: 'Topics',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                  ),
                  selectedIcon: Icon(
                    Icons.account_balance_wallet_rounded,
                  ),
                  label: 'Wallet',
                ),
                NavigationDestination(
                  icon:
                  Icon(Icons.person_outline_rounded),
                  selectedIcon:
                  Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.topics,
    required this.attempts,
  });

  final List<QuizTopic> topics;
  final List<QuizAttempt> attempts;
}

class _HomeDashboard extends StatefulWidget {
  const _HomeDashboard({
    required this.user,
    required this.revision,
    required this.onOpenTopics,
    required this.onOpenWallet,
    required this.onOpenProgress,
    required this.onQuizFinished,
  });

  final AppUser user;
  final int revision;
  final VoidCallback onOpenTopics;
  final VoidCallback onOpenWallet;
  final VoidCallback onOpenProgress;
  final VoidCallback onQuizFinished;

  @override
  State<_HomeDashboard> createState() =>
      _HomeDashboardState();
}

class _HomeDashboardState
    extends State<_HomeDashboard> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(
      covariant _HomeDashboard oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.revision != widget.revision) {
      _future = _load();
    }
  }

  Future<_HomeData> _load() async {
    final topics = await quizRepository.loadTopics();
    final attempts =
    await quizProgressService.loadAttempts();

    return _HomeData(
      topics: topics,
      attempts: attempts,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _openTopic(QuizTopic topic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizListScreen(
          topic: topic,
          onQuizFinished:
          widget.onQuizFinished,
        ),
      ),
    );
  }

  void _openQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizDetailsScreen(
          quiz: quiz,
          onQuizFinished:
          widget.onQuizFinished,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user.name.trim();
    final displayName = name.isEmpty
        ? 'শিক্ষার্থী'
        : name.split(' ').first;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20, 22, 20, 28,
        ),
        children: [
          Row(
            children: [
              Container(
                height: 47,
                width: 47,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFF2D6B57),
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Color(0xFFF5D99C),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learn Islam',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    Text(
                      'ISLAM QUIZ',
                      style: TextStyle(
                        color:
                        Color(0xFFADCCC0),
                        letterSpacing: 1.6,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFF254B42),
                borderRadius:
                BorderRadius.circular(25),
                child: InkWell(
                  onTap:
                  widget.onOpenWallet,
                  borderRadius:
                  BorderRadius.circular(25),
                  child: const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.toll_rounded,
                          color:
                          Color(0xFFF5D99C),
                          size: 20,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 31),
          Text(
            'আসসালামু আলাইকুম, $displayName',
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'আজ নতুন কিছু শিখি ও নিজের জ্ঞান যাচাই করি।',
            style: TextStyle(
              color: Color(0xFFB8D0C6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<_HomeData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _MessageCard(
                  message:
                  'Quiz data বা progress load হয়নি। '
                      'Assets পরীক্ষা করে আবার চেষ্টা করুন।',
                  onRetry: _refresh,
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(55),
                  child: Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      Color(0xFFF5D99C),
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              final allQuizzes = data.topics
                  .expand(
                    (topic) => topic.quizzes,
              )
                  .toList();

              final now = DateTime.now();
              final todayQuizIds =
              data.attempts
                  .where((attempt) {
                final date = attempt
                    .completedAt
                    .toLocal();

                return date.year ==
                    now.year &&
                    date.month ==
                        now.month &&
                    date.day ==
                        now.day;
              })
                  .map(
                    (attempt) =>
                attempt.quizId,
              )
                  .toSet();

              final todayCount =
              todayQuizIds.length > 5
                  ? 5
                  : todayQuizIds.length;

              return Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  _DailyCard(
                    count: todayCount,
                    onStart:
                    widget.onOpenTopics,
                    onProgress:
                    widget.onOpenProgress,
                  ),
                  const SizedBox(height: 30),
                  _SectionTitle(
                    title: 'Quiz Category',
                    action:
                    'সব দেখুন',
                    onAction:
                    widget.onOpenTopics,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection:
                      Axis.horizontal,
                      itemCount:
                      data.topics.length,
                      separatorBuilder:
                          (_, _) =>
                      const SizedBox(
                        width: 11,
                      ),
                      itemBuilder:
                          (context, index) {
                        final topic =
                        data.topics[index];

                        return _CategoryTile(
                          topic: topic,
                          index: index,
                          onTap: () =>
                              _openTopic(
                                topic,
                              ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  _SectionTitle(
                    title: 'আরও Quiz',
                    action:
                    'সব দেখুন',
                    onAction:
                    widget.onOpenTopics,
                  ),
                  const SizedBox(height: 15),
                  if (allQuizzes.isEmpty)
                    const _MessageCard(
                      message:
                      'এখনো কোনো quiz নেই।',
                    )
                  else
                    LayoutBuilder(
                      builder:
                          (context, constraints) {
                        final width =
                            (constraints.maxWidth -
                                12) /
                                2;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final quiz
                            in allQuizzes
                                .take(4))
                              SizedBox(
                                width: width,
                                child:
                                _QuizCard(
                                  quiz: quiz,
                                  onTap: () =>
                                      _openQuiz(
                                        quiz,
                                      ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: widget
                        .onOpenProgress,
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      const Color(
                        0xFFF5D99C,
                      ),
                      side: const BorderSide(
                        color:
                        Color(0xFF779E8F),
                      ),
                      minimumSize:
                      const Size(0, 48),
                    ),
                    icon: const Icon(
                      Icons.insights_rounded,
                    ),
                    label: const Text(
                      'আমার অগ্রগতি',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.count,
    required this.onStart,
    required this.onProgress,
  });

  final int count;
  final VoidCallback onStart;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          begin: Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            Color(0xFF2C6955),
            Color(0xFF184438),
          ],
        ),
        borderRadius:
        BorderRadius.circular(26),
        border: Border.all(
          color: const Color(
            0xFF6D9B82,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 57,
                width: 57,
                decoration:
                BoxDecoration(
                  color: const Color(
                    0xFF3F8068,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(18),
                ),
                child: const Icon(
                  Icons
                      .menu_book_rounded,
                  color: Color(
                    0xFFF5D99C,
                  ),
                  size: 31,
                ),
              ),
              const SizedBox(
                width: 14,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'আজকের লক্ষ্য',
                      style: TextStyle(
                        color:
                        Colors.white,
                        fontSize: 19,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '৫টি ভিন্ন Quiz '
                          'সম্পন্ন করুন',
                      style: TextStyle(
                        color: Color(
                          0xFFD0E4D9,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap:
                onProgress,
                child: const Icon(
                  Icons
                      .arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 22,
          ),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            child:
            LinearProgressIndicator(
              value:
              count / 5,
              minHeight: 8,
              backgroundColor:
              Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation(
                Color(0xFFF5D99C),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                '$count / 5 সম্পন্ন',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed:
                onStart,
                style: TextButton
                    .styleFrom(
                  foregroundColor:
                  const Color(
                    0xFFF5D99C,
                  ),
                ),
                child:
                const Text(
                  'Quiz খেলুন',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 21,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed:
          onAction,
          style:
          TextButton.styleFrom(
            foregroundColor:
            const Color(
              0xFFF5D99C,
            ),
          ),
          child:
          Text(action),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.topic,
    required this.index,
    required this.onTap,
  });

  final QuizTopic topic;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons
          .auto_stories_rounded,
      Icons
          .nights_stay_rounded,
      Icons
          .favorite_outline_rounded,
      Icons
          .lightbulb_outline_rounded,
    ];

    const colors = [
      Color(0xFF9EDBBB),
      Color(0xFFF4D394),
      Color(0xFFDAACDC),
      Color(0xFFAAD2E8),
    ];

    final color =
    colors[index % colors.length];

    return SizedBox(
      width: 118,
      child: Material(
        color:
        const Color(0xFF1F423A),
        borderRadius:
        BorderRadius.circular(
          21,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(
            21,
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(
              12,
            ),
            child: Column(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration:
                  BoxDecoration(
                    color: color
                        .withValues(
                      alpha: 0.14,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      16,
                    ),
                  ),
                  child: Icon(
                    icons[index %
                        icons.length],
                    color: color,
                    size: 27,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  topic.title,
                  textAlign:
                  TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Colors.white,
                    fontSize: 12,
                    fontWeight:
                    FontWeight
                        .w700,
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

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.quiz,
    required this.onTap,
  });

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final premium =
        quiz.isPremium;

    return Material(
      color: const Color(
        0xFF1D413B,
      ),
      borderRadius:
      BorderRadius.circular(
        24,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          24,
        ),
        child: Padding(
          padding:
          const EdgeInsets.all(
            12,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Container(
                height: 92,
                width:
                double.infinity,
                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin: Alignment
                        .topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: premium
                        ? const [
                      Color(
                        0xFF8A6838,
                      ),
                      Color(
                        0xFF3A362F,
                      ),
                    ]
                        : const [
                      Color(
                        0xFF3D9172,
                      ),
                      Color(
                        0xFF205A59,
                      ),
                    ],
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    17,
                  ),
                ),
                child: Icon(
                  premium
                      ? Icons
                      .workspace_premium_rounded
                      : Icons
                      .auto_stories_rounded,
                  color:
                  const Color(
                    0xFFFFE8AF,
                  ),
                  size: 53,
                ),
              ),
              const SizedBox(
                height: 13,
              ),
              Text(
                quiz.title,
                maxLines: 2,
                overflow:
                TextOverflow
                    .ellipsis,
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 15,
                  fontWeight:
                  FontWeight
                      .w800,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                premium
                    ? 'Premium • '
                    '${quiz.coinCost} coins'
                    : 'Free • '
                    '${quiz.questions.length}টি প্রশ্ন',
                style:
                TextStyle(
                  color: premium
                      ? const Color(
                    0xFFF5D99C,
                  )
                      : const Color(
                    0xFFB9DAC9,
                  ),
                  fontSize: 11,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 10,
                ),
                decoration:
                BoxDecoration(
                  color: premium
                      ? const Color(
                    0xFFEBD3A1,
                  )
                      : const Color(
                    0xFFBDE7D0,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
                  ),
                ),
                child: Text(
                  premium
                      ? 'বিস্তারিত'
                      : 'Quiz শুরু করুন',
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color: Color(
                      0xFF173B34,
                    ),
                    fontSize: 12,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback?
  onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFF254B42,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              Colors.white,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed:
              onRetry,
              child:
              const Text(
                'আবার চেষ্টা করুন',
              ),
            ),
        ],
      ),
    );
  }
}