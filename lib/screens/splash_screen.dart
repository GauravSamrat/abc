import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Add kiya
import '../controllers/map_controller.dart'; // 👈 Add kiya
import 'dashboard_screen.dart';
import 'onboarding_screen.dart'; // 👈 Add kiya

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random(42);
  late List<_LeafParticle> _leaves;

  @override
  void initState() {
    super.initState();

    // 15 seconds animation sequence
    _leaves = List.generate(18, (i) {
      final angle = _random.nextDouble() * 2 * pi;
      final startRadius = 20 + _random.nextDouble() * 30;
      final endRadius = 100 + _random.nextDouble() * 150;
      final delay = 0.25 + _random.nextDouble() * 0.4;
      final size = 4.0 + _random.nextDouble() * 8;
      return _LeafParticle(angle, startRadius, endRadius, delay, size);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _goToDashboard();
      }
    });
  }

  void _goToDashboard() {
    final controller = Provider.of<MapController>(context, listen: false);

    // 👈 NAYA: Check karo ki onboarding complete hui hai ya nahi
    final nextScreen = !controller.hasCompletedOnboarding
        ? const OnboardingScreen()
        : const DashboardScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1500),
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch colors dynamically from the current theme
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final creamText = theme.colorScheme.onSurface;
    final goldAccent = theme.colorScheme.primary;

    return GestureDetector(
      onTap: _goToDashboard,
      child: Scaffold(
        backgroundColor: bgColor,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final size = MediaQuery.of(context).size;
            final cx = size.width / 2;
            final cy = size.height / 2 - 40;

            final glowOpacity = (t / 0.2).clamp(0.0, 1.0);
            final iconScale = Curves.easeOutCubic
                .transform(((t - 0.13) / 0.3).clamp(0.0, 1.0));
            final iconOpacity = ((t - 0.13) / 0.2).clamp(0.0, 1.0);
            final titleOpacity = ((t - 0.4) / 0.2).clamp(0.0, 1.0);
            final titleSlide = (1 - titleOpacity) * 20;
            final taglineOpacity = ((t - 0.6) / 0.2).clamp(0.0, 1.0);
            final pulse = sin(t * pi * 6) * 0.02 + 1.0;

            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Glow Effect Behind Logo
                Positioned(
                  child: Opacity(
                    opacity: glowOpacity * 0.15,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goldAccent,
                        boxShadow: [
                          BoxShadow(
                            color: goldAccent.withValues(alpha: 0.5),
                            blurRadius: 100,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Leaves Particles
                ..._leaves.map((leaf) {
                  final leafProgress = ((t - leaf.delay) / 0.5).clamp(0.0, 1.0);
                  if (leafProgress <= 0) return const SizedBox.shrink();

                  final radius = leaf.startRadius +
                      (leaf.endRadius - leaf.startRadius) * leafProgress;
                  final x = cx + cos(leaf.angle) * radius;
                  final y = cy + sin(leaf.angle) * radius - (leafProgress * 30);
                  final opacity = (1.0 - leafProgress * 0.8).clamp(0.0, 1.0);

                  return Positioned(
                    left: x - leaf.size / 2,
                    top: y - leaf.size / 2,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: leaf.size,
                        height: leaf.size,
                        decoration: BoxDecoration(
                          color: creamText.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),

                // 👈 MAIN LOGO (App Icon Style with Shadow)
                Center(
                  // 👈 Positioned ki jagah Center kiya
                  child: Opacity(
                    opacity: iconOpacity,
                    child: Transform.scale(
                      scale: pulse,
                      child: Transform.scale(
                        scale: iconScale,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(36), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // TEXT SECTION
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: Offset(0, titleSlide),
                        child: Opacity(
                          opacity: titleOpacity,
                          child: Column(
                            children: [
                              // 1. App Name (Small logo hataya, text chhota kiya)
                              Text(
                                'a bodhi chitta',
                                style: TextStyle(
                                  color: creamText,
                                  fontSize: 28, // Font size adjust kiya
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 3, // Spacing badhayi
                                ),
                              ),
                              const SizedBox(height: 12),

                              // 2. Tagline
                              Opacity(
                                opacity: taglineOpacity,
                                child: Text(
                                  'THE MIND THAT AWAKENS',
                                  style: TextStyle(
                                    color: creamText.withValues(alpha: 0.6),
                                    fontSize: 11,
                                    letterSpacing: 6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LeafParticle {
  final double angle;
  final double startRadius;
  final double endRadius;
  final double delay;
  final double size;
  const _LeafParticle(
      this.angle, this.startRadius, this.endRadius, this.delay, this.size);
}
