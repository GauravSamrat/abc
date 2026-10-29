import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
// import '../models/node_model.dart';
import '../screens/node_detail_sheet.dart';

class TableView extends StatelessWidget {
  final String? parentId;
  const TableView({super.key, required this.parentId});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final nodes = controller.getChildren(parentId);

    if (nodes.isEmpty) {
      return const Center(
        child: Text('No data to show in table.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('TITLE',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))),
              Expanded(
                  flex: 2,
                  child: Text('TYPE',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))),
              Expanded(
                  flex: 5,
                  child: Text('NOTES',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))),
              SizedBox(width: 40), // Space for Edit Icon
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];
              final nodeColor =
                  Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')));

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1E1E24),
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (context) => NodeDetailSheet(node: node),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: nodeColor, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                node.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: nodeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              node.type.toUpperCase(),
                              style: TextStyle(
                                  color: nodeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          node.notes.isEmpty ? '—' : node.notes,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blueAccent, size: 18),
                        tooltip: 'Edit Node',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Theme.of(context).cardColor,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24))),
                            builder: (context) => NodeDetailSheet(node: node),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
