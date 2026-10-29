import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Add karein
import '../controllers/map_controller.dart'; // 👈 Add karein

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  Timer? _timer;

  int _selectedMinutes = 5;
  int _secondsRemaining = 5 * 60;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Breathing Animation Controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds per breath
    )..repeat(reverse: true); // Inhale / Exhale
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleMeditation() {
    if (_isPlaying) {
      // Pause
      _timer?.cancel();
      _breathingController.stop();
      setState(() => _isPlaying = false);
    } else {
      // Play
      _breathingController.repeat(reverse: true);
      setState(() => _isPlaying = true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _breathingController.stop();
          setState(() => _isPlaying = false);
          _showCompletionDialog();
        }
      });
    }
  }

  void _setTime(int minutes) {
    _timer?.cancel();
    _breathingController.stop();
    setState(() {
      _selectedMinutes = minutes;
      _secondsRemaining = minutes * 60;
      _isPlaying = false;
    });
  }

  void _showCompletionDialog() {
    // 👇 Data save karein jab session poora ho
    final controller = Provider.of<MapController>(context, listen: false);
    controller.saveMeditationSession(_selectedMinutes * 60);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('🙏 Session Complete',
            style: TextStyle(color: Colors.green)),
        content: Text(
          'You have successfully meditated for $_selectedMinutes minutes. Carry this peace with you.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Close Meditation Screen
            },
            child:
                const Text('Done', style: TextStyle(color: Color(0xFFE8D5B7))),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141E), // Deep Calm Blue/Black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Meditation',
            style: TextStyle(
                color: Colors.white54, letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Breathing Animation Circle
          Center(
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                final scale =
                    0.8 + (_breathingController.value * 0.3); // 0.8 to 1.1
                return Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8D5B7).withValues(
                            alpha: 0.15 + (_breathingController.value * 0.1)),
                        blurRadius: 60,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE8D5B7).withValues(alpha: 0.3),
                            const Color(0xFFE8D5B7).withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                            color:
                                const Color(0xFFE8D5B7).withValues(alpha: 0.5),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _formatTime(_secondsRemaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),

          // Instruction Text
          Text(
            _isPlaying
                ? (_breathingController.value < 0.5
                    ? 'Breathe In...'
                    : 'Breathe Out...')
                : 'Ready to Meditate?',
            style: TextStyle(
              color: const Color(0xFFE8D5B7).withValues(alpha: 0.8),
              fontSize: 18,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 60),

          // Time Selector
          if (!_isPlaying)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [5, 10, 15, 20].map((mins) {
                final isSelected = _selectedMinutes == mins;
                return GestureDetector(
                  onTap: () => _setTime(mins),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8D5B7).withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE8D5B7)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      '$mins m',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFE8D5B7)
                            : Colors.white54,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 40),

          // Play/Pause Button
          GestureDetector(
            onTap: _toggleMeditation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8D5B7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8D5B7).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
