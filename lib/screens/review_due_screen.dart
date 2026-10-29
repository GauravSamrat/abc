import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../widgets/app_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'focus_mode_screen.dart';
// import 'package:intl/intl.dart'; // 👈 Yeh add karo

class ReviewDueScreen extends StatefulWidget {
  const ReviewDueScreen({super.key});

  @override
  State<ReviewDueScreen> createState() => _ReviewDueScreenState();
}

class _ReviewDueScreenState extends State<ReviewDueScreen> {
  bool _isRevealed = false; // 👈 Flashcard State

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final dueNodes = controller.dueNodes;
    final theme = Theme.of(context);

    // Agar koi due node nahi hai
    if (dueNodes.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        bottomNavigationBar: const AppBottomNav(currentIndex: 2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('All caught up!',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w300)),
              const SizedBox(height: 8),
              Text('No nodes are due for review right now.',
                  style: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      );
    }

    // 👇 Sabse urgent node uthao (dueDate ke hisaab se sort karke)
    dueNodes.sort((a, b) => (a.dueDate ?? '').compareTo(b.dueDate ?? ''));
    final node = dueNodes.first;

    // 👈 YEH LINES MISSING THI
    bool isUpcoming = false;
    if (node.dueDate != null) {
      final dt = DateTime.parse(node.dueDate!);
      if (dt.isAfter(DateTime.now())) {
        isUpcoming = true;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          ),
        ),
        title: Text('Daily Review',
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // 👈 Yeh add kiya
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon & Strength
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${node.strength}% STRENGTH',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ),
                        Icon(Icons.psychology,
                            color: theme.colorScheme.primary, size: 24),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(node.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w300)),
                    const SizedBox(height: 16),

                    // 👈 NAYA: Flashcard Reveal Logic
                    if (!_isRevealed && node.notes.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _isRevealed = true),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.touch_app,
                                  color: theme.colorScheme.primary, size: 24),
                              const SizedBox(height: 8),
                              Text('Tap to reveal answer',
                                  style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    else if (node.notes.isNotEmpty)
                      Text(node.notes,
                          textAlign: TextAlign.center,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                              fontSize: 15,
                              height: 1.6)),

                    const SizedBox(height: 40),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUpcoming
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.05)
                              : theme.colorScheme.primary,
                          foregroundColor: isUpcoming
                              ? theme.colorScheme.onSurface
                              : theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: isUpcoming ? 0 : 5,
                        ),
                        onPressed: () {
                          controller.reviewNode(node.id);
                          // Next card ke liye reset karo
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) setState(() => _isRevealed = false);
                          });
                        },
                        child: Text(
                            isUpcoming
                                ? 'Review Early (+34%)'
                                : 'Review Now (+34%)',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FocusModeScreen(node: node)));
                      },
                      child: Text('Open Full Node',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
