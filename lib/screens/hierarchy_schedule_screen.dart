import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/map_controller.dart';
import 'node_detail_sheet.dart';

class HierarchyScheduleScreen extends StatefulWidget {
  final String? parentId;
  const HierarchyScheduleScreen({super.key, required this.parentId});

  @override
  State<HierarchyScheduleScreen> createState() =>
      _HierarchyScheduleScreenState();
}

class _HierarchyScheduleScreenState extends State<HierarchyScheduleScreen> {
  String _selectedTimeRange = '7 Days'; // '7 Days', '1 Month', '1 Year'

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            const Text('Master Schedule', style: TextStyle(letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 👇 1. Time Range Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['7 Days', '1 Month', '1 Year'].map((range) {
                final isSelected = _selectedTimeRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(range),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _selectedTimeRange = range),
                    selectedColor: const Color(0xFFE8D5B7),
                    backgroundColor: theme.cardColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 👇 2. Main Tree & Suggestions List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section 1: Scheduled Hierarchy
                Text(
                  'SCHEDULED TASKS ($_selectedTimeRange)',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                ..._buildHierarchyTree(
                    context, controller, widget.parentId, theme),

                const SizedBox(height: 30),

                // Section 2: Smart Suggestions for Empty Slots
                Text(
                  'SMART SUGGESTIONS (Fill Empty Slots)',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                _buildSmartSuggestions(context, controller, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Recursive Hierarchy Builder
  List<Widget> _buildHierarchyTree(BuildContext context,
      MapController controller, String? parentId, ThemeData theme) {
    final children = controller.getChildren(parentId);
    if (children.isEmpty) return [];

    List<Widget> widgets = [];
    for (var node in children) {
      // 👇 YAHAN FIX: nodeColor define kiya gaya hai
      final nodeColor =
          Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')));

      final hasChildren = controller.getChildren(node.id).isNotEmpty;

      // Time string
      String timeStr = '';
      if (node.dueDate != null) {
        timeStr =
            DateFormat('MMM dd, hh:mm a').format(DateTime.parse(node.dueDate!));
      } else if (node.routineTime != null) {
        timeStr = 'Daily at ${node.routineTime}';
      }

      if (hasChildren) {
        // Expandable Parent
        widgets.add(
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: nodeColor.withValues(alpha: 0.15), // 👈 FIX APPLIED
                    shape: BoxShape.circle),
                child: Icon(Icons.folder_open,
                    color: nodeColor, size: 20), // 👈 FIX APPLIED
              ),
              title: Text(node.title,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15)),
              subtitle: timeStr.isNotEmpty
                  ? Text(timeStr,
                      style: TextStyle(color: nodeColor, fontSize: 12))
                  : null,
              children:
                  _buildHierarchyTree(context, controller, node.id, theme),
            ),
          ),
        );
      } else {
        // Leaf Node (No checkbox)
        widgets.add(
          ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.cardColor,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => NodeDetailSheet(node: node),
              );
            },
            leading: Icon(
              node.type == 'study'
                  ? Icons.school
                  : (node.type == 'task'
                      ? Icons.check_circle_outline
                      : Icons.notes),
              color: nodeColor, // 👈 FIX APPLIED
              size: 20,
            ),
            title: Text(node.title,
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 14)),
            subtitle: timeStr.isNotEmpty
                ? Text(timeStr,
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11))
                : null,
            trailing: Icon(Icons.arrow_forward_ios,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          ),
        );
      }
    }
    return widgets;
  }

  // Smart Suggestions Logic
  Widget _buildSmartSuggestions(
      BuildContext context, MapController controller, ThemeData theme) {
    final unscheduledNodes = controller.nodes
        .where((n) =>
            n.dueDate == null && n.routineTime == null && n.type != 'note')
        .take(5)
        .toList();

    if (unscheduledNodes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
        child: const Text('All tasks are scheduled! Great job.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: unscheduledNodes.map((node) {
        final nodeColor =
            Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')));
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFE8D5B7).withValues(alpha: 0.3)),
          ),
          child: ListTile(
            // 👇 YAHAN FIX: Pehle hardcoded color tha, ab nodeColor use kiya
            leading: Icon(Icons.lightbulb_outline, color: nodeColor),
            title: Text(node.title,
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 14)),
            subtitle: const Text('Unscheduled - Tap to schedule',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.cardColor,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => NodeDetailSheet(node: node),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
