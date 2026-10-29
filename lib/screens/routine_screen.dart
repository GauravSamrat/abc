import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import 'node_detail_sheet.dart';

class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final routineNodes = controller.todaysRoutineNodes;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            const Text("Today's Routine", style: TextStyle(letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: routineNodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement,
                      size: 64,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('No routines for today.\nGo add some in your maps!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routineNodes.length,
              itemBuilder: (context, index) {
                final node = routineNodes[index];
                final nodeColor =
                    Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')));

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: node.isCompleted
                            ? Colors.green.withValues(alpha: 0.5)
                            : nodeColor.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.cardColor,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (context) => NodeDetailSheet(node: node),
                      );
                    },
                    leading: GestureDetector(
                      onTap: () => controller.toggleNodeCompletion(node.id),
                      child: Icon(
                        node.isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: node.isCompleted ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      node.title,
                      style: TextStyle(
                        color: node.isCompleted
                            ? Colors.grey
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        decoration: node.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: node.type == 'study'
                        ? Text('Study Node • ${node.strength}% Memory',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey))
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
