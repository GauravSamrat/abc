import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import 'schedule_view.dart';
import '../views/tiles_view.dart';
import '../views/board_view.dart';
import '../views/table_view.dart';
import '../views/radial_view.dart';
import '../views/canvas_view.dart';
import '../widgets/app_bottom_nav.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late PageController _pageController;
  late List<MindMapView> _unlockedViews;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<MapController>(context, listen: false);
    // Filter out outline and swipe for a cleaner UI
    _unlockedViews = MindMapView.values
        .where((v) =>
            controller.isViewUnlocked(v) &&
            v != MindMapView.swipe &&
            v != MindMapView.outline)
        .toList();
    if (_unlockedViews.isEmpty) _unlockedViews = [MindMapView.outline];
    final idx = _unlockedViews.indexOf(controller.currentView);
    _currentPage = idx >= 0 ? idx : 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    if (controller.activeMapId == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text('Pick a map from Home',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardRedirect()),
                  (r) => false,
                ),
                child: const Text('Go Home',
                    style: TextStyle(color: Color(0xFFE8D5B7))),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      );
    }

    final activeMap = controller.nodes.firstWhere(
        (n) => n.id == controller.activeMapId,
        orElse: () => controller.nodes.first);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                setState(() => _currentPage = idx);
                controller.changeView(_unlockedViews[idx]);
              },
              itemCount: _unlockedViews.length,
              itemBuilder: (ctx, idx) =>
                  _buildViewFor(ctx, controller, _unlockedViews[idx]),
            ),

            // 👇 NAYA: Minimal View Switcher Pill (Bottom Center)
            if (_unlockedViews.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showViewPicker(context, controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getViewIcon(_unlockedViews[_currentPage]),
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _unlockedViews[_currentPage].name.toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.expand_more,
                            size: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'add_btn_ws',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.scaffoldBackgroundColor,
        onPressed: () => _showQuickAddDialog(context, controller, activeMap.id),
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildViewFor(
      BuildContext context, MapController controller, MindMapView view) {
    final activeId = controller.activeMapId;
    switch (view) {
      case MindMapView.outline:
        // 👈 Outline ko bhi TilesView bana do
        return TilesView(parentId: activeId);
      case MindMapView.swipe:
        return const Center(
            child: Text('Swipe view coming soon',
                style: TextStyle(color: Colors.grey)));
      case MindMapView.tiles:
        return TilesView(parentId: activeId);
      case MindMapView.board:
        return BoardView(parentId: activeId);
      case MindMapView.table:
        return TableView(parentId: activeId);
      case MindMapView.radial:
        return RadialView(parentId: activeId);
      case MindMapView.timeline:
        return ScheduleView(parentId: activeId);
      case MindMapView.canvas:
        return CanvasView(parentId: activeId);
    }
  }

  // 👇 NAYA: Minimal View Picker Sheet
  void _showViewPicker(BuildContext context, MapController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _unlockedViews.map((view) {
              final isSelected = _unlockedViews[_currentPage] == view;
              return GestureDetector(
                onTap: () {
                  final idx = _unlockedViews.indexOf(view);
                  _pageController.animateToPage(
                    idx,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  Navigator.pop(ctx);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2)
                            : Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        _getViewIcon(view),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      view.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getViewIcon(MindMapView view) {
    switch (view) {
      case MindMapView.outline:
        return Icons.view_agenda_outlined;
      case MindMapView.swipe:
        return Icons.view_carousel_outlined;
      case MindMapView.tiles:
        return Icons.grid_view_rounded;
      case MindMapView.board:
        return Icons.view_kanban_outlined;
      case MindMapView.table:
        return Icons.table_chart_outlined;
      case MindMapView.radial:
        return Icons.hub_outlined;
      case MindMapView.timeline:
        return Icons.calendar_month;
      case MindMapView.canvas:
        return Icons.dashboard_outlined;
    }
  }

  // 👈 NAYA: Quick Add Dialog
  void _showQuickAddDialog(
      BuildContext context, MapController controller, String parentId) {
    final TextEditingController textCtrl = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Quick Capture',
          style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w300),
        ),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              controller.addChildNode(parentId, title: val.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (textCtrl.text.trim().isNotEmpty) {
                controller.addChildNode(parentId, title: textCtrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Node'),
          ),
        ],
      ),
    );
  }
}

// Placeholder for redirect (avoid circular import)
class DashboardRedirect extends StatelessWidget {
  const DashboardRedirect({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// // 👈 PERFORMANCE FIX: Extract tree into StatelessWidget
// class _TreeBuilderWidget extends StatelessWidget {
//   final MapController controller;
//   final String? parentId;
//   final int depth;
//   final Function(MindMapNode) onOpenFocus;
//   final Function(MindMapNode) onEditNode;

//   const _TreeBuilderWidget({
//     required this.controller,
//     required this.parentId,
//     required this.depth,
//     required this.onOpenFocus,
//     required this.onEditNode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final children = controller.getChildren(parentId);
//     if (children.isEmpty) return const SizedBox.shrink();

//     return ReorderableListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       buildDefaultDragHandles: false,
//       itemCount: children.length,
//       onReorderItem: (oldIndex, newIndex) {
//         controller.reorderNodes(parentId, oldIndex, newIndex);
//       },
//       itemBuilder: (context, index) {
//         final node = children[index];
//         final isDimmed = controller.filterStrength != null &&
//             node.strength != controller.filterStrength;

//         return Opacity(
//           key: ValueKey(node.id),
//           opacity: isDimmed ? 0.15 : 1.0,
//           child: Padding(
//             padding: EdgeInsets.only(left: depth * 24.0, bottom: 8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: theme.cardColor,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                         color:
//                             theme.colorScheme.primary.withValues(alpha: 0.3)),
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: ListTile(
//                       onTap: () => onOpenFocus(node),
//                       dense: true,
//                       leading: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (node.type == 'task')
//                             GestureDetector(
//                               onTap: () =>
//                                   controller.toggleNodeCompletion(node.id),
//                               child: Icon(
//                                   node.isCompleted
//                                       ? Icons.check_circle
//                                       : Icons.radio_button_unchecked,
//                                   color: node.isCompleted
//                                       ? Colors.green
//                                       : Colors.grey,
//                                   size: 22),
//                             )
//                           else
//                             Icon(
//                               node.type == 'idea'
//                                   ? Icons.lightbulb_outline
//                                   : (depth == 0
//                                       ? Icons.folder_open
//                                       : Icons.notes),
//                               color: theme.colorScheme.primary,
//                               size: 20,
//                             ),
//                           const SizedBox(width: 8),
//                           if (depth > 0)
//                             const Icon(Icons.subdirectory_arrow_right,
//                                 color: Colors.grey, size: 16),
//                         ],
//                       ),
//                       title: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               node.title,
//                               style: TextStyle(
//                                 color: node.isCompleted
//                                     ? Colors.grey
//                                     : theme.colorScheme.onSurface,
//                                 fontWeight: FontWeight.w500,
//                                 decoration: node.isCompleted
//                                     ? TextDecoration.lineThrough
//                                     : null,
//                               ),
//                             ),
//                           ),
//                           if (node.type == 'study')
//                             Container(
//                               margin: const EdgeInsets.only(right: 6),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 6, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withValues(alpha: 0.15),
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(
//                                     color: Colors.green.withValues(alpha: 0.5)),
//                               ),
//                               child: Text('${node.strength}%',
//                                   style: const TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                         ],
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (controller.getChildren(node.id).isNotEmpty)
//                             GestureDetector(
//                               onTap: () =>
//                                   controller.toggleNodeCollapse(node.id),
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 margin: const EdgeInsets.only(right: 8),
//                                 decoration: BoxDecoration(
//                                   color: theme.colorScheme.primary
//                                       .withValues(alpha: 0.1),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                       color: theme.colorScheme.primary
//                                           .withValues(alpha: 0.3)),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       node.isCollapsed
//                                           ? Icons.add
//                                           : Icons.remove,
//                                       size: 12,
//                                       color: theme.colorScheme.primary,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       '${controller.getChildren(node.id).length}',
//                                       style: TextStyle(
//                                           color: theme.colorScheme.primary,
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           IconButton(
//                             icon: const Icon(Icons.edit_outlined,
//                                 color: Colors.grey, size: 20),
//                             onPressed: () => onEditNode(node),
//                           ),
//                           ReorderableDragStartListener(
//                             index: index,
//                             child: const Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 4.0),
//                               child: Icon(Icons.drag_indicator,
//                                   color: Colors.grey, size: 20),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.add_circle_outline,
//                                 color: theme.colorScheme.primary),
//                             onPressed: () => controller.addChildNode(node.id),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (!node.isCollapsed)
//                   _TreeBuilderWidget(
//                     controller: controller,
//                     parentId: node.id,
//                     depth: depth + 1,
//                     onOpenFocus: onOpenFocus,
//                     onEditNode: onEditNode,
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
