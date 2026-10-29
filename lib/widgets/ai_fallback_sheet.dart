import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';

class AiFallbackSheet extends StatefulWidget {
  final String topic;
  const AiFallbackSheet({super.key, required this.topic});

  @override
  State<AiFallbackSheet> createState() => _AiFallbackSheetState();
}

class _AiFallbackSheetState extends State<AiFallbackSheet> {
  final TextEditingController _jsonCtrl = TextEditingController();
  bool _isImporting = false;

  // 👇 The Magic Prompt (AI ke liye specially design kiya gaya)
  String get _aiPrompt => '''
Act as an expert curriculum designer and JSON generator. I want to create a mind map for "${widget.topic}".

I need you to convert this topic into a highly structured JSON array of mind map nodes that matches my app's schema. 

Here is the exact JSON format required:
[
  {
    "id": "unique_id_1",
    "title": "Main Topic Name",
    "parentId": null,
    "type": "study",
    "notes": "Brief introduction to this topic. You can use Markdown formatting like **bold** or ## Heading.",
    "colorHex": "#9C89B8",
    "order": 0
  },
  {
    "id": "unique_id_2",
    "title": "Sub-topic 1",
    "parentId": "unique_id_1",
    "type": "study",
    "notes": "Detailed notes for sub-topic 1. Keep it concise but informative.",
    "colorHex": "#5E8C61",
    "order": 1
  }
]

Rules:
1. The first node must be the root topic (parentId: null).
2. Break down the topic into logical sub-nodes and their children.
3. The 'type' should be 'study' for theoretical nodes, or 'task' for actionable steps.
4. Generate unique IDs for every node (e.g., node_1, node_2).
5. Output ONLY the valid JSON array. Do not add any conversational text.
''';

  void _copyPrompt() {
    Clipboard.setData(ClipboardData(text: _aiPrompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Prompt copied! Paste it in ChatGPT/Claude.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _importJson() async {
    if (_jsonCtrl.text.trim().isEmpty) return;
    setState(() => _isImporting = true);

    try {
      final List<dynamic> decoded = jsonDecode(_jsonCtrl.text);
      final newNodes = decoded.map((e) => MindMapNode.fromJson(e)).toList();
      final count = await Provider.of<MapController>(context, listen: false)
          .importNodesFromJson(newNodes);

      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '🎉 Successfully imported $count nodes! Check your Dashboard.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '❌ Invalid JSON format. Make sure you copied the whole output.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create "${widget.topic}" with AI ✨',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find exactly what you need. But don\'t worry, you can build it in 3 easy steps.',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Step 1
            _buildStepTitle('1', 'Copy the AI Prompt'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _copyPrompt,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Magic Prompt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Step 2
            _buildStepTitle('2', 'Generate JSON in ChatGPT/Claude'),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20, left: 32),
              child: Text(
                'Paste the prompt into any AI along with your chapter/book text.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12),
              ),
            ),

            // Step 3
            _buildStepTitle('3', 'Paste the JSON output here'),
            const SizedBox(height: 12),
            TextField(
              controller: _jsonCtrl,
              maxLines: 5,
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText:
                    '[\n  {\n    "id": "node_1",\n    "title": "Physics",...\n  }\n]',
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Import Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isImporting ? null : _importJson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isImporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Import to Abcitta 🚀',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(String number, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle),
          child: Center(
              child: Text(number,
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
