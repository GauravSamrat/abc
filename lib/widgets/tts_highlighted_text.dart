import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/tts_controller.dart';

class TtsHighlightedText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const TtsHighlightedText({
    super.key,
    required this.text,
    required this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ttsController = Provider.of<TtsController>(context);

    if (!ttsController.isSpeaking) {
      // Normal state: just show the text
      return Text(text, style: baseStyle);
    }

    // 👈 SPEED LOGIC: Slow vs Fast highlighting
    bool isSlow = ttsController.speechRate <= 0.5;

    // If slow: highlight word. If fast: highlight paragraph/line.
    // For simplicity, here we'll implement word-level highlighting first.
    // Paragraph-level can be added by finding nearest \n boundaries.

    int start = ttsController.startOffset;
    int end = ttsController.endOffset;

    // Ensure offsets are within bounds
    if (start < 0) start = 0;
    if (end > text.length) end = text.length;
    if (start > end) start = end;

    final String before = text.substring(0, start);
    final String current = text.substring(start, end);
    final String after = text.substring(end);

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: current,
            style: baseStyle.copyWith(
              backgroundColor: isSlow
                  ? Colors.yellow.withValues(alpha: 0.3)
                  : Colors.blue
                      .withValues(alpha: 0.2), // Different color for fast mode
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
