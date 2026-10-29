import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import '../screens/focus_mode_screen.dart';
import '../screens/node_detail_sheet.dart';

class TilesView extends StatefulWidget {
  final String? parentId;
  const TilesView({super.key, required this.parentId});

  @override
  State<TilesView> createState() => _TilesViewState();
}

class _TilesViewState extends State<TilesView> {
  // Track karo kaunse parents expand hue hain
  final Set<String> _expandedParents = {};

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    Theme.of(context);
    final parents = controller.getChildren(widget.parentId);

    if (parents.isEmpty) {
      return const Center(
          child: Text('No nodes here.', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: parents.map((parentNode) {
              final isExpanded = _expandedParents.contains(parentNode.id);
              return _ExpandableParentTile(
                key: ValueKey(parentNode.id),
                node: parentNode,
                isExpanded: isExpanded,
                onToggle: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedParents.remove(parentNode.id);
                    } else {
                      _expandedParents.add(parentNode.id);
                    }
                  });
                },
                children: controller.getChildren(parentNode.id),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 📦 PARENT TILE (Expandable)
// ==========================================
class _ExpandableParentTile extends StatefulWidget {
  final MindMapNode node;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<MindMapNode> children;

  const _ExpandableParentTile({
    super.key,
    required this.node,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  State<_ExpandableParentTile> createState() => _ExpandableParentTileState();
}

class _ExpandableParentTileState extends State<_ExpandableParentTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor =
        Color(int.parse(widget.node.colorHex.replaceFirst('#', '0xFF')));
    final hasChildren = widget.children.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // Expanded hone par width badha do taaki children fit ho sakein
        width: widget.isExpanded ? 340 : 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? baseColor.withValues(alpha: 0.8)
                : baseColor.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: baseColor.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 2,
              )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Section (Parent Header)
              InkWell(
                onTap: () {
                  // Agar direct padhna hai toh Focus Mode kholo, warna expand toggle karo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FocusModeScreen(node: widget.node)),
                  );
                },
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: theme.cardColor,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (context) => NodeDetailSheet(node: widget.node),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        baseColor.withValues(alpha: 0.1),
                        theme.cardColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.folder_outlined,
                              color: baseColor, size: 20),
                          if (widget.node.type == 'study')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: baseColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.node.strength}%',
                                style: TextStyle(
                                    color: baseColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.node.title,
                        maxLines: widget.isExpanded ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section (Expand/Collapse Icon)
              if (hasChildren)
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                      border: Border(
                          top: BorderSide(
                              color:
                                  theme.dividerColor.withValues(alpha: 0.1))),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isExpanded
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            size: 14,
                            color: baseColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.children.length}',
                            style: TextStyle(
                                color: baseColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Expanded Children Section
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: widget.isExpanded
                    ? Container(
                        width: 340,
                        padding: const EdgeInsets.all(12),
                        color: theme.scaffoldBackgroundColor
                            .withValues(alpha: 0.3),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.children.map((child) {
                            return _ChildTile(node: child);
                          }).toList(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 📦 CHILD TILE (Opens Focus Mode)
// ==========================================
class _ChildTile extends StatefulWidget {
  final MindMapNode node;
  const _ChildTile({required this.node});

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor =
        Color(int.parse(widget.node.colorHex.replaceFirst('#', '0xFF')));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FocusModeScreen(node: widget.node)),
          );
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: theme.cardColor,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => NodeDetailSheet(node: widget.node),
          );
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 140, // Chhota size
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? baseColor.withValues(alpha: 0.1)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: baseColor.withValues(alpha: _isHovered ? 0.6 : 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.node.type == 'task'
                      ? Icons.check_circle_outline
                      : widget.node.type == 'game'
                          ? Icons.sports_esports_outlined
                          : widget.node.type == 'qna'
                              ? Icons.help_outline
                              : Icons.notes,
                  size: 14,
                  color: baseColor,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.node.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
