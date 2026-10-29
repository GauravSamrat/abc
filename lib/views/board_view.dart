import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import '../screens/node_detail_sheet.dart';

class BoardView extends StatelessWidget {
  final String? parentId;
  const BoardView({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final allNodes = controller.getChildren(parentId);

    final notes = allNodes.where((n) => n.type == 'note').toList();
    final tasks = allNodes.where((n) => n.type == 'task').toList();
    final ideas = allNodes.where((n) => n.type == 'idea').toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumn(context, controller, 'NOTES', notes, Icons.notes,
            const Color(0xFFA5A58D)),
        _buildColumn(context, controller, 'TASKS', tasks,
            Icons.check_circle_outline, const Color(0xFFD4A373)),
        _buildColumn(context, controller, 'IDEAS', ideas,
            Icons.lightbulb_outline, const Color(0xFFB5838D)),
      ],
    );
  }

  Widget _buildColumn(BuildContext context, MapController controller,
      String title, List<MindMapNode> nodes, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 8),
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('${nodes.length}',
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            Expanded(
              child: nodes.isEmpty
                  ? Center(
                      child: Text('Empty',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 12)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: nodes.length,
                      itemBuilder: (context, index) {
                        final node = nodes[index];
                        final nodeColor = Color(
                            int.parse(node.colorHex.replaceFirst('#', '0xFF')));

                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: const Color(0xFF1E1E24),
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24))),
                              builder: (context) => NodeDetailSheet(node: node),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: nodeColor.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (node.type == 'task')
                                      GestureDetector(
                                        onTap: () => controller
                                            .toggleNodeCompletion(node.id),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Icon(
                                            node.isCompleted
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: node.isCompleted
                                                ? Colors.green
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        node.title,
                                        style: TextStyle(
                                          color: node.isCompleted
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          decoration: node.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (node.notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(node.notes,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11)),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
