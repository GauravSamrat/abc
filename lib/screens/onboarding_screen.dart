import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String? _role;
  String? _focus;

  // 👇 Emojis + Icons for Cute UI
  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Student',
      'emoji': '👨‍🎓',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF9C89B8)
    },
    {
      'title': 'Teacher',
      'emoji': '👩‍🏫',
      'icon': Icons.co_present_outlined,
      'color': const Color(0xFF5E8C61)
    },
    {
      'title': 'Explorer',
      'emoji': '🚀',
      'icon': Icons.explore_outlined,
      'color': const Color(0xFF7B9EA8)
    },
    {
      'title': 'Professional',
      'emoji': '💼',
      'icon': Icons.work_outline,
      'color': const Color(0xFFD4A373)
    },
  ];

  final List<Map<String, dynamic>> _classes = [
    {'title': 'Class 6-8', 'emoji': '🏫'},
    {'title': 'Class 9-10', 'emoji': '📚'},
    {'title': 'Class 11-12', 'emoji': '🎓'},
    {'title': 'College', 'emoji': '🏛️'},
  ];

  final List<Map<String, dynamic>> _focuses = [
    {'title': 'Study & Exams', 'emoji': '📖', 'icon': Icons.menu_book_outlined},
    {
      'title': 'Games & Fun',
      'emoji': '🎮',
      'icon': Icons.sports_esports_outlined
    },
    {
      'title': 'Daily Tasks',
      'emoji': '✅',
      'icon': Icons.checklist_rtl_outlined
    },
    {'title': 'Mindfulness', 'emoji': '🧘', 'icon': Icons.self_improvement},
  ];

  final List<Map<String, dynamic>> _interests = [
    {
      'title': 'Science',
      'emoji': '🔬',
      'icon': Icons.science_outlined,
      'color': const Color(0xFF5E8C61)
    },
    {
      'title': 'Maths',
      'emoji': '📐',
      'icon': Icons.calculate_outlined,
      'color': const Color(0xFF9C89B8)
    },
    {
      'title': 'Coding',
      'emoji': '💻',
      'icon': Icons.code,
      'color': const Color(0xFF7B9EA8)
    },
    {
      'title': 'History',
      'emoji': '📜',
      'icon': Icons.history_edu_outlined,
      'color': const Color(0xFFCB997E)
    },
    {
      'title': 'Fitness',
      'emoji': '🏋️',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFD4A373)
    },
    {
      'title': 'Habits',
      'emoji': '🌱',
      'icon': Icons.loop,
      'color': const Color(0xFFB5838D)
    },
    {
      'title': 'Psychology',
      'emoji': '🧠',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF7B9EA8)
    },
  ];

  void _nextStep() {
    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<MapController>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0.05, 0), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
            );
          },
          child: _buildStepContent(theme, controller),
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, MapController controller) {
    switch (_currentStep) {
      case 0:
        return _buildQuestionScreen(
          key: const ValueKey(0),
          title: 'Who are you? 👋',
          subtitle: 'Take your time, we are here for you.',
          options: _roles,
          onSelected: (val) {
            _role = val;
            if (val == 'Student') {
              _nextStep();
            } else {
              setState(() => _currentStep = 2);
            }
          },
        );
      case 1:
        return _buildClassScreen(theme);
      case 2:
        return _buildQuestionScreen(
          key: const ValueKey(2),
          title: 'Your primary focus? 🎯',
          subtitle: 'We will personalize your dashboard based on this.',
          options: _focuses,
          onSelected: (val) {
            _focus = val;
            _nextStep();
          },
        );
      case 3:
        return _buildInterestScreen(theme, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 0 & 2 UI (Now Center Aligned & Cute)
  Widget _buildQuestionScreen({
    required Key key,
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> options,
    required Function(String) onSelected,
  }) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.primary, // 👈 Highlighted Color
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 12),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 15)),
            const SizedBox(height: 48),

            // 👈 Cute Wrap Layout instead of Grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: options.map((opt) {
                return _buildOptionCard(
                  title: opt['title'],
                  emoji: opt['emoji'],
                  icon: opt['icon'],
                  color: opt['color'] ?? theme.colorScheme.primary,
                  onTap: () => onSelected(opt['title']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1 UI
  Widget _buildClassScreen(ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey(1),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text('Which class are you in? 🏫',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 48),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _classes.map((c) {
                return _buildOptionCard(
                  title: c['title'],
                  emoji: c['emoji'],
                  icon: null,
                  color: theme.colorScheme.primary,
                  onTap: () {
                    _nextStep();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3 UI (The Final Seed)
  Widget _buildInterestScreen(ThemeData theme, MapController controller) {
    return SingleChildScrollView(
      key: const ValueKey(3),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Text('Explore right now? 🌱',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    height: 1.2)),
            const SizedBox(height: 12),
            Text('Pick one, and we\'ll plant the first seed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 15)),
            const SizedBox(height: 48),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _interests.map((opt) {
                return _buildOptionCard(
                  title: opt['title'],
                  emoji: opt['emoji'],
                  icon: opt['icon'],
                  color: opt['color'],
                  onTap: () async {
                    await controller.completeOnboarding(
                      role: _role ?? 'Explorer',
                      focus: _focus ?? 'Study',
                      interest: opt['title'],
                    );
                    if (mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DashboardScreen()));
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 👈 NAYA: Small, Cute Pill-Shaped Card
  Widget _buildOptionCard(
      {required String title,
      String? emoji,
      IconData? icon,
      required Color color,
      required VoidCallback onTap}) {
    return _HoverCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24), // Rounded pill
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
            ],
            Text(title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// Simple Hover Effect
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverCard({required this.child, required this.onTap});
  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
