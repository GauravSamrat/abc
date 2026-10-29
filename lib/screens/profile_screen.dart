import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/map_controller.dart';
import '../utils/time_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);
    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';

    // 👇 DATA CALCULATION
    final allNodes = controller.nodes;

    // Level System (Milestone-based, Phase 7)
    final level = controller.userLevel;
    final levelTitle = controller.userLevelTitle;
    final completedCount = controller.userProgressCount;
    final nextMilestone = controller.userNextMilestone;
    final currentLevelMin = level <= 1
        ? 0
        : (level == 2 ? 5 : (level == 3 ? 10 : (level == 4 ? 15 : 25)));
    final progress = nextMilestone == currentLevelMin
        ? 1.0
        : ((completedCount - currentLevelMin) /
                (nextMilestone - currentLevelMin))
            .clamp(0.0, 1.0);

    // Time & Meditation
    final totalTimeSeconds =
        allNodes.fold<int>(0, (sum, n) => sum + n.timeSpentSeconds);
    final meditationToday = controller.getMeditationToday();
    final meditationStreak = controller.meditationStreak;
    final focusStreak = controller.focusStreak;

    // Tasks
    final totalTasks = allNodes.where((n) => n.type == 'task').length;
    final completedTasks =
        allNodes.where((n) => n.type == 'task' && n.isCompleted).length;
    final dueTasks = controller.dueNodes.length;

    // Community & Sharing (Simulated for now)
    const sharedMaps = 0;

    // Node Analytics handled by MapController caching

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            color: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$value Screen Coming Soon!'),
                  backgroundColor: Colors.blueAccent));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'Community',
                  child: Row(children: [
                    Icon(Icons.people, size: 18, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text('Community')
                  ])),
              const PopupMenuItem(
                  value: 'Live Quizzes',
                  child: Row(children: [
                    Icon(Icons.quiz, size: 18, color: Colors.purpleAccent),
                    SizedBox(width: 10),
                    Text('Live Quizzes')
                  ])),
              const PopupMenuItem(
                  value: 'Live Games',
                  child: Row(children: [
                    Icon(Icons.sports_esports,
                        size: 18, color: Colors.orangeAccent),
                    SizedBox(width: 10),
                    Text('Live Games')
                  ])),
              const PopupMenuItem(
                  value: 'Live Study',
                  child: Row(children: [
                    Icon(Icons.school, size: 18, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Live Study')
                  ])),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE8D5B7),
          labelColor: const Color(0xFFE8D5B7),
          unselectedLabelColor:
              theme.colorScheme.onSurface.withValues(alpha: 0.5),
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 18)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 18)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 👇 TAB 1: OVERVIEW
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar & Level Badge
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5B7).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFE8D5B7), width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFE8D5B7)
                                    .withValues(alpha: 0.3),
                                blurRadius: 20)
                          ],
                        ),
                        child: const Center(
                            child: Icon(Icons.person,
                                size: 50, color: Color(0xFFE8D5B7))),
                      ),
                      const SizedBox(height: 16),
                      Text(userEmail,
                          style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFE8D5B7), Color(0xFFD4A373)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Level $level • $levelTitle',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // XP Progress Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level $level',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold)),
                          Text('$completedCount / $nextMilestone nodes',
                              style: const TextStyle(
                                  color: Color(0xFFE8D5B7),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor:
                              theme.dividerColor.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFE8D5B7)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Complete study nodes to earn XP and level up!',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats Grid
                Row(
                  children: [
                    _buildQuickStatCard(
                        context,
                        'Total Focus Time',
                        formatTimeSpent(totalTimeSeconds),
                        Icons.timer,
                        Colors.orangeAccent),
                    const SizedBox(width: 12),
                    _buildQuickStatCard(
                        context,
                        'Meditation (Today)',
                        formatTimeSpent(meditationToday),
                        Icons.self_improvement,
                        Colors.teal),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildQuickStatCard(
                        context,
                        'Tasks Done',
                        '$completedTasks / $totalTasks',
                        Icons.check_circle_outline,
                        Colors.green),
                    const SizedBox(width: 12),
                    _buildQuickStatCard(context, 'Due / Pending', '$dueTasks',
                        Icons.warning_amber_rounded, Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),

          // 👇 TAB 2: ANALYTICS
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 NAYA: Minimal Mastery Ring (Level 1-3)
                if (level < 4) ...[
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: completedCount /
                                    (nextMilestone == 0 ? 1 : nextMilestone),
                                strokeWidth: 12,
                                backgroundColor:
                                    theme.dividerColor.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$completedCount',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'of $nextMilestone',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Master $nextMilestone nodes to reach Level ${level + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete 3 reviews to master a node.',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],

                // 👇 LEVEL 4 UNLOCK: Heavy Analytics
                if (level >= 4) ...[
                  Text('WELLNESS',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildAnalyticsCard(
                          context,
                          'Meditation Streak',
                          '$meditationStreak Days',
                          Icons.self_improvement,
                          Colors.teal),
                      const SizedBox(width: 12),
                      _buildAnalyticsCard(
                          context,
                          'Focus Streak',
                          '$focusStreak Days',
                          Icons.local_fire_department,
                          Colors.orangeAccent),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                // Meditation & Streaks
                Text('WELLNESS',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAnalyticsCard(
                        context,
                        'Meditation Streak',
                        '$meditationStreak Days',
                        Icons.self_improvement,
                        Colors.teal),
                    const SizedBox(width: 12),
                    _buildAnalyticsCard(
                        context,
                        'Focus Streak',
                        '$focusStreak Days',
                        Icons.local_fire_department,
                        Colors.orangeAccent),
                  ],
                ),
                const SizedBox(height: 24),

                // Community & Sharing
                Text('COMMUNITY & SHARING',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildAnalyticsCard(context, 'Maps Shared', '$sharedMaps',
                        Icons.share, Colors.blueAccent),
                    const SizedBox(width: 12),
                    _buildAnalyticsCard(
                        context,
                        'Nodes Created',
                        '${allNodes.length}',
                        Icons.create,
                        Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. TOP TIME SPENT NODES
                Text('MOST TIME SPENT',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                if (controller.topTimeNodes.isEmpty)
                  _buildEmptyAnalyticsCard(context, 'No focus sessions yet.')
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1))),
                    child: Column(
                      children: controller.topTimeNodes.map((n) {
                        final percent = n.timeSpentSeconds /
                            controller.topTimeNodes.first.timeSpentSeconds;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(n.title,
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                      '${(n.timeSpentSeconds / 60).toStringAsFixed(0)}m',
                                      style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 4,
                                  backgroundColor:
                                      theme.dividerColor.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 24),

                // 2. STRENGTH DISTRIBUTION
                Text('STRENGTH DISTRIBUTION',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1))),
                  child: Column(
                    children: controller.strengthDistribution.entries.map((e) {
                      final totalNodes = controller.nodes
                          .where((n) => n.type == 'study')
                          .length;
                      final percent =
                          totalNodes == 0 ? 0.0 : e.value / totalNodes;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(e.key,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: 11)),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 8,
                                  backgroundColor:
                                      theme.dividerColor.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(e.value.toString(),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text('NODE STRENGTHS',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                if (controller.needsAttentionNodes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.eco_outlined,
                              color: Colors.orangeAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Ready for a refresh',
                              style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold))
                        ]),
                        const SizedBox(height: 12),
                        // 👇 Riya's fix: Scrollable list for ALL weak nodes
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.needsAttentionNodes.length,
                            itemBuilder: (ctx, idx) {
                              final n = controller.needsAttentionNodes[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(n.title,
                                            style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                                fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis)),
                                    Text('${n.strength}%',
                                        style: const TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👇 HELPER WIDGETS
  Widget _buildQuickStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // 👇 NAYA: Missing Helper Method
  Widget _buildEmptyAnalyticsCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
