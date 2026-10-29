import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../screens/dashboard_screen.dart';
import '../screens/workspace_screen.dart';
import '../screens/review_due_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/store_screen.dart';
import '../screens/meditation_screen.dart';
import '../screens/mind_garden_screen.dart';
import '../screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  Future<void> _navigate(BuildContext context, int index) async {
    if (index == currentIndex && index != 3) {
      return; // Hub (3) can open even if selected
    }

    switch (index) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (r) => false,
        );
        break;
      case 1:
        final ctrl = Provider.of<MapController>(context, listen: false);
        if (ctrl.activeMapId == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Pick a map first')));
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WorkspaceScreen()),
          (r) => false,
        );
        break;
      case 2:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ReviewDueScreen()),
          (r) => false,
        );
        break;
      case 3:
        _showHubMenu(context);
        break;
    }
  }

  void _showHubMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),

              // 👈 Hub Icons with Hover Effect
              Wrap(
                spacing: 28,
                runSpacing: 28,
                alignment: WrapAlignment.center,
                children: [
                  _HubIconButton(
                    icon: Icons.forest,
                    label: 'Forest',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MindGardenScreen()));
                    },
                  ),
                  _HubIconButton(
                    icon: Icons.person,
                    label: 'Profile',
                    color: theme.colorScheme.primary,
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (FirebaseAuth.instance.currentUser == null) {
                        final signedIn = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()));
                        if (signedIn == true && context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ProfileScreen()));
                        }
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()));
                      }
                    },
                  ),
                  _HubIconButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()));
                    },
                  ),
                  _HubIconButton(
                    icon: Icons.storefront,
                    label: 'Store',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StoreScreen()));
                    },
                  ),
                  _HubIconButton(
                    icon: Icons.self_improvement,
                    label: 'Meditate',
                    color: theme.colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MeditationScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _navigate(context, i),
      backgroundColor: theme.cardColor,
      indicatorColor: const Color(0xFFE8D5B7).withValues(alpha: 0.3),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      height: 60,
      elevation: 0,
      destinations: const [
        NavigationDestination(
            icon: _AnimatedNavIcon(icon: Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFFE8D5B7)),
            label: 'Home'),
        NavigationDestination(
            icon: _AnimatedNavIcon(icon: Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Color(0xFFE8D5B7)),
            label: 'Map'),
        NavigationDestination(
            icon: _AnimatedNavIcon(icon: Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: Color(0xFFE8D5B7)),
            label: 'Review'),
        NavigationDestination(
            icon: _AnimatedNavIcon(icon: Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Color(0xFFE8D5B7)),
            label: 'Hub'),
      ],
    );
  }
}

// ==========================================
// 👇 NAYA: Hub Icon Button (Stateful for Hover)
// ==========================================
class _HubIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HubIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HubIconButton> createState() => _HubIconButtonState();
}

class _HubIconButtonState extends State<_HubIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        widget.color.withValues(alpha: _isHovered ? 0.5 : 0.2),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.25),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  widget.icon,
                  color: _isHovered
                      ? widget.color
                      : widget.color.withValues(alpha: 0.8),
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 👇 NAYA: Animated Bottom Nav Icon
// ==========================================
class _AnimatedNavIcon extends StatefulWidget {
  final IconData icon;
  const _AnimatedNavIcon({required this.icon});

  @override
  State<_AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<_AnimatedNavIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Icon(
          widget.icon,
          color: _isHovered
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
