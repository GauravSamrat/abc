import 'package:abcitta/screens/workspace_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'dart:convert';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import 'node_detail_sheet.dart'; // 👈 YEH IMPORT MISSING HAI
import 'routine_screen.dart';
import '../widgets/course_tile.dart'; // 👈 naya
import '../widgets/app_bottom_nav.dart';
import 'search_screen.dart';
import 'profile_screen.dart'; // 👈 add kiya
import 'login_screen.dart'; // 👈 add kiya
import 'package:firebase_auth/firebase_auth.dart'; // 👈 add kiya

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 👇 Minimal Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _HoverProfileHeader(
                      controller: controller,
                      onTap: () async {
                        // 👈 NAYA: Header se Profile open karne ka logic
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
                    Row(
                      children: [
                        // Search (Tree icon hata diya)
                        _HoverIconButton(
                          icon: Icons.search,
                          color: theme.colorScheme.onSurface,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SearchScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 👇 Today's Routine Progress Card
              if (controller
                  .getScheduleForDate(DateTime.now())
                  .where((n) => n.type == 'task')
                  .isNotEmpty)
                _buildTodayProgressCard(context, controller, theme),

              // 👇 Main Folders Grid (No Swipe)
              const _FolderCarousel(),

              const SizedBox(height: 100), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      floatingActionButton: _HoverFAB(
        onTap: () => _showCreateMapDialog(context, controller, theme),
      ),
    );
  }

  Widget _buildTodayProgressCard(
      BuildContext context, MapController controller, ThemeData theme) {
    final todayTasks = controller
        .getScheduleForDate(DateTime.now())
        .where((n) => n.type == 'task')
        .toList();
    final completedTasks = todayTasks.where((n) => n.isCompleted).length;
    final totalTasks = todayTasks.length;
    final progress = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
            theme.colorScheme.primary.withValues(alpha: 0.1), theme.cardColor),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFE8D5B7).withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeWidth: 8,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Routine',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedTasks of $totalTasks tasks completed',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                color: theme.colorScheme.primary, size: 20),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RoutineScreen()));
            },
          )
        ],
      ),
    );
  }

  void _showCreateMapDialog(
      BuildContext context, MapController controller, ThemeData theme) {
    TextEditingController textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('New Folder',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: textCtrl,
          style: TextStyle(color: theme.colorScheme.onSurface),
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter name (e.g., Study, Tasks)...',
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (textCtrl.text.trim().isNotEmpty) {
                controller.addRootNode(textCtrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Create',
                style: TextStyle(color: Color(0xFFE8D5B7))),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 👇 Folder Grid (3-Column with Air)
// ==========================================
class _FolderCarousel extends StatelessWidget {
  const _FolderCarousel();

  IconData _getFolderIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('study') || t.contains('class') || t.contains('course')) {
      return Icons.school_outlined;
    }
    if (t.contains('task') || t.contains('todo') || t.contains('work')) {
      return Icons.checklist_rtl_outlined;
    }
    if (t.contains('money') ||
        t.contains('financ') ||
        t.contains('budget') ||
        t.contains('asset')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (t.contains('project')) return Icons.work_outline;
    if (t.contains('idea') || t.contains('thought')) {
      return Icons.lightbulb_outline;
    }
    if (t.contains('note')) return Icons.edit_note_outlined;
    if (t.contains('book') || t.contains('library') || t.contains('read')) {
      return Icons.menu_book_outlined;
    }
    if (t.contains('routine') || t.contains('daily')) {
      return Icons.event_repeat_outlined;
    }
    if (t.contains('archive') || t.contains('old')) {
      return Icons.archive_outlined;
    }
    return Icons.folder_outlined; // Default
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);
    final rawMaps = controller.getChildren(null);

    if (rawMaps.isEmpty) {
      final textCtrl = TextEditingController();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'What\'s on your mind?',
                style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 8),
              Text(
                'Start with a single thought.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: textCtrl,
                autofocus: true,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: theme.colorScheme.onSurface, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'e.g., Study, Tasks, Ideas...',
                  hintStyle: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.3))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.colorScheme.primary)),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    controller.addRootNode(val.trim());
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    // Custom Sorting Logic
    final maps = List<MindMapNode>.from(rawMaps);
    const orderPriority = {
      'tasks': 1,
      'money': 2,
      'study': 3,
      'projects': 4,
      'ideas': 5,
      'notes': 6,
    };
    maps.sort((a, b) {
      final pA = orderPriority[a.title.toLowerCase()] ?? 99;
      final pB = orderPriority[b.title.toLowerCase()] ?? 99;
      if (pA != pB) return pA.compareTo(pB);
      return a.title.compareTo(b.title); // Fallback for others
    });

    // 3-Column Grid Layout with More Air
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              mainAxisExtent: 110,
            ),
            itemCount: maps.length,
            itemBuilder: (context, index) {
              final map = maps[index];
              final baseColor =
                  Color(int.parse(map.colorHex.replaceFirst('#', '0xFF')));
              final totalNodes = controller.getTotalNodes(map.id);
              final estTime = controller.getEstimatedTime(map.id);
              final iconData = _getFolderIcon(map.title);

              return CourseTile(
                title: map.title,
                subtitle: '$totalNodes nodes',
                timeText: estTime,
                coverImageUrl: map.coverImageUrl,
                baseColor: baseColor,
                defaultIcon: iconData,
                onTap: () {
                  controller.setActiveMap(map.id);
                  controller
                      .changeView(MindMapView.tiles); // 👈 Force Tiles View
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkspaceScreen(),
                    ),
                  );
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: theme.cardColor,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => NodeDetailSheet(node: map),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 👇 NAYA: Premium Hover Animations
// ==========================================

class _HoverProfileHeader extends StatefulWidget {
  final MapController controller;
  final VoidCallback onTap;
  const _HoverProfileHeader({required this.controller, required this.onTap});

  @override
  State<_HoverProfileHeader> createState() => _HoverProfileHeaderState();
}

class _HoverProfileHeaderState extends State<_HoverProfileHeader> {
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
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        if (_isHovered)
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/logo.png',
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LVL ${widget.controller.userLevel}',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.controller.masteredNodesCount}/${widget.controller.userNextMilestone} Mastered',
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _HoverIconButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 24),
          ),
        ),
      ),
    );
  }
}

class _HoverFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _HoverFAB({required this.onTap});

  @override
  State<_HoverFAB> createState() => _HoverFABState();
}

class _HoverFABState extends State<_HoverFAB> {
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
          curve: Curves.easeOutBack,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary
                      .withValues(alpha: _isHovered ? 0.5 : 0.3),
                  blurRadius: _isHovered ? 15 : 8,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child:
                Icon(Icons.add, color: theme.scaffoldBackgroundColor, size: 24),
          ),
        ),
      ),
    );
  }
}
