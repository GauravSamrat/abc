import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/map_controller.dart';
// import '../models/node_model.dart';
import 'node_detail_sheet.dart';
import 'hierarchy_schedule_screen.dart'; // 👈 Ye add karo

class ScheduleView extends StatefulWidget {
  final String? parentId;
  const ScheduleView({super.key, required this.parentId});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    // Selected date ka schedule nikalna
    final scheduleNodes = controller.getScheduleForDate(_selectedDate);

    return Column(
      children: [
        // 👇 NAYA: Header with "Master Schedule" Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.account_tree_outlined,
                    color: Color(0xFFE8D5B7)),
                tooltip: 'Master Schedule',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HierarchyScheduleScreen(parentId: widget.parentId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 1. WEEKLY CALENDAR STRIP
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: theme.cardColor.withValues(alpha: 0.3),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7, // Aaj se agle 7 din
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = DateUtils.isSameDay(date, _selectedDate);
              final dayTasks = controller.getScheduleForDate(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8D5B7)
                        : theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        index == 0 ? 'Today' : DateFormat('EEE').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : theme.colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Task Count Badge
                      if (dayTasks.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black.withValues(alpha: 0.2)
                                : const Color(0xFFE8D5B7)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${dayTasks.length}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFFE8D5B7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 2. DAILY TIMELINE
        Expanded(
          child: scheduleNodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available,
                          size: 60,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text('No tasks scheduled for this day.',
                          style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scheduleNodes.length,
                  itemBuilder: (context, index) {
                    final node = scheduleNodes[index];
                    final nodeColor = Color(
                        int.parse(node.colorHex.replaceFirst('#', '0xFF')));

                    // Time format karna
                    String timeStr = 'Anytime';
                    if (node.dueDate != null) {
                      final dt = DateTime.parse(node.dueDate!);
                      timeStr = DateFormat('hh:mm a').format(dt);
                    } else if (node.routineTime != null &&
                        node.routineTime!.isNotEmpty) {
                      final parts = node.routineTime!.split(':');
                      final dt = DateTime(
                          2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
                      timeStr = DateFormat('hh:mm a').format(dt);
                    }

                    return InkWell(
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
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: node.isCompleted
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : nodeColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            // Time Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeStr,
                                    style: TextStyle(
                                        color: nodeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                    node.routineDays.isNotEmpty
                                        ? 'ROUTINE'
                                        : 'TASK',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Vertical Line
                            Container(
                                width: 2,
                                height: 40,
                                color:
                                    theme.dividerColor.withValues(alpha: 0.2)),
                            const SizedBox(width: 16),
                            // Title
                            Expanded(
                              child: Text(
                                node.title,
                                style: TextStyle(
                                  color: node.isCompleted
                                      ? Colors.grey
                                      : theme.colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: node.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            // Checkbox
                            GestureDetector(
                              onTap: () =>
                                  controller.toggleNodeCompletion(node.id),
                              child: Icon(
                                node.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: node.isCompleted
                                    ? Colors.green
                                    : Colors.grey,
                                size: 28,
                              ),
                            )
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
