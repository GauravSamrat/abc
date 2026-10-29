import 'dart:math';
import 'dart:async';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import '../screens/focus_mode_screen.dart';
import '../screens/node_detail_sheet.dart';

class RadialView extends StatefulWidget {
  final String? parentId;
  const RadialView({super.key, required this.parentId});

  @override
  State<RadialView> createState() => _RadialViewState();
}

class _RadialViewState extends State<RadialView> {
  final TransformationController _transformController =
      TransformationController();
  String? _selectedNodeId;
  String? _draggingNodeId;
  final Map<String, Offset> _localPositions = {};

  // 👈 FIX: Snapshot for drag
  Map<String, Offset> _dragStartPositions = {};

  Offset _dragStartPosition = Offset.zero;
  bool _isActuallyDragging = false;

  bool _hasCentered = false;
  bool _hasLoadedState = false;
  Timer? _saveViewStateTimer;

  @override
  void initState() {
    super.initState();
    _loadViewState();
    _transformController.addListener(_onViewChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onViewChanged);
    _saveViewStateTimer?.cancel();
    _saveViewState();
    super.dispose();
  }

  void _onViewChanged() {
    _saveViewStateTimer?.cancel();
    _saveViewStateTimer =
        Timer(const Duration(seconds: 2), () => _saveViewState());
  }

  Future<void> _loadViewState() async {
    if (widget.parentId == null) {
      _hasLoadedState = true;
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _hasLoadedState = true;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('view_states')
          .doc('radial_${widget.parentId}')
          .get();

      if (doc.exists && doc.data()?['matrix'] != null) {
        final List<dynamic> rawMatrix = doc.data()!['matrix'];

        // 👈 FIX: dynamic list ko safely double list mein convert karo
        final List<double> matrixData =
            rawMatrix.map((e) => (e as num).toDouble()).toList();

        if (mounted) {
          _transformController.value =
              Matrix4.fromList(matrixData); // 👈 Matrix4.fromList use karo
          _hasLoadedState = true;
          _hasCentered = true;
        }
      } else {
        if (mounted) _hasLoadedState = true;
      }
    } catch (e) {
      debugPrint('Error loading view state: $e');
      if (mounted) _hasLoadedState = true;
    }
  }

  Future<void> _saveViewState() async {
    if (widget.parentId == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final matrixData = _transformController.value.storage.toList();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('view_states')
          .doc('radial_${widget.parentId}')
          .set({'matrix': matrixData}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving view state: $e'); // 👈 Fixed Empty Catch
    }
  }

  List<MindMapNode> _getVisibleNodes(MapController controller) {
    final visible = <MindMapNode>[];
    if (widget.parentId != null) {
      final parentNode = controller.nodes.firstWhere(
          (n) => n.id == widget.parentId,
          orElse: () =>
              MindMapNode(id: 'dummy', title: 'Parent', parentId: null));
      if (parentNode.id != 'dummy') visible.add(parentNode);
    }
    void traverse(String? pid) {
      final children = controller.getChildren(pid);
      for (var c in children) {
        visible.add(c);
        if (!c.isCollapsed) traverse(c.id);
      }
    }

    traverse(widget.parentId);
    return visible;
  }

  Map<String, Offset> _calculatePositions(List<MindMapNode> visibleNodes) {
    final positions = <String, Offset>{};
    const center = Offset(1500, 1500);

    if (widget.parentId != null) {
      final parentNode =
          visibleNodes.firstWhere((n) => n.id == widget.parentId);
      final hasCustom = parentNode.x != 0 || parentNode.y != 0;
      final safeX = parentNode.x.clamp(100.0, 2900.0);
      final safeY = parentNode.y.clamp(100.0, 2900.0);
      positions[widget.parentId!] = _localPositions[widget.parentId!] ??
          (hasCustom ? Offset(safeX, safeY) : center);
    }

    final roots =
        visibleNodes.where((n) => n.parentId == widget.parentId).toList();
    for (int i = 0; i < roots.length; i++) {
      final node = roots[i];
      double angle = (i * 2 * pi) / (roots.isEmpty ? 1 : roots.length);
      double defaultX = center.dx + 280 * cos(angle);
      double defaultY = center.dy + 280 * sin(angle);

      final hasCustom = node.x != 0 || node.y != 0;
      final safeX = node.x.clamp(100.0, 2900.0);
      final safeY = node.y.clamp(100.0, 2900.0);
      positions[node.id] = _localPositions[node.id] ??
          (hasCustom ? Offset(safeX, safeY) : Offset(defaultX, defaultY));
    }

    final queue = List<MindMapNode>.from(roots);
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final children =
          visibleNodes.where((n) => n.parentId == current.id).toList();
      final parentPos = positions[current.id]!;

      double parentAngle =
          atan2(parentPos.dy - center.dy, parentPos.dx - center.dx);

      for (int i = 0; i < children.length; i++) {
        final child = children[i];

        const double spread = pi * 0.8;
        double startAngle = parentAngle - spread / 2;
        double step = children.length > 1 ? spread / (children.length - 1) : 0;
        double childAngle = startAngle + i * step;

        const double dist = 220.0;
        Offset defaultPos = Offset(parentPos.dx + dist * cos(childAngle),
            parentPos.dy + dist * sin(childAngle));

        final hasCustom = child.x != 0 || child.y != 0;
        final safeX = child.x.clamp(100.0, 2900.0);
        final safeY = child.y.clamp(100.0, 2900.0);

        positions[child.id] = _localPositions[child.id] ??
            (hasCustom ? Offset(safeX, safeY) : defaultPos);
        queue.add(child);
      }
    }
    return positions;
  }

  void _autoFit(Map<String, Offset> positions) {
    if (positions.isEmpty || !mounted) return;
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (var pos in positions.values) {
      minX = min(minX, pos.dx);
      maxX = max(maxX, pos.dx);
      minY = min(minY, pos.dy);
      maxY = max(maxY, pos.dy);
    }

    minX -= 200;
    maxX += 200;
    minY -= 200;
    maxY += 200;
    final width = maxX - minX;
    final height = maxY - minY;
    if (width <= 0 || height <= 0) return;

    final screenSize = MediaQuery.of(context).size;
    final scale = min(screenSize.width / width, screenSize.height / height)
        .clamp(0.1, 1.0);
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;

    final matrix = Matrix4.identity()
      ..translateByDouble(screenSize.width / 2, screenSize.height / 2, 0.0, 1.0)
      ..scaleByDouble(scale, scale, scale, 1.0)
      ..translateByDouble(-centerX, -centerY, 0.0, 1.0);

    _transformController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);
    final visibleNodes = _getVisibleNodes(controller);

    if (visibleNodes.isEmpty) {
      return const Center(
          child: Text('No nodes to map.\nAdd children to see the radial view!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)));
    }

    final positions = _calculatePositions(visibleNodes);

    if (!_hasCentered && _hasLoadedState && positions.isNotEmpty) {
      _hasCentered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoFit(positions));
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedNodeId = null),
      child: InteractiveViewer(
        transformationController: _transformController,
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.1,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(2000),
        constrained: false,
        child: SizedBox(
          width: 3000,
          height: 3000,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GridPainter())),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConnectionPainter(
                      nodes: controller.nodes,
                      visibleNodes: visibleNodes,
                      positions: positions,
                      selectedId: _selectedNodeId,
                      theme: theme),
                ),
              ),
              ...visibleNodes.map((node) {
                final currentPos = positions[node.id]!;
                final baseColor =
                    Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')));
                return Positioned(
                  left: currentPos.dx - 45,
                  top: currentPos.dy - 45,
                  child: _buildDraggableOrb(context, controller, node,
                      baseColor, currentPos, positions),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableOrb(
      BuildContext context,
      MapController controller,
      MindMapNode node,
      Color baseColor,
      Offset currentPos,
      Map<String, Offset> allPositions) {
    final isSelected = _selectedNodeId == node.id;
    final isDragging = _draggingNodeId == node.id;

    return GestureDetector(
      onPanStart: (details) {
        _dragStartPosition = details.globalPosition;
        _isActuallyDragging = false;
        _dragStartPositions = Map.from(allPositions); // 👈 Snapshot
        setState(() {
          _draggingNodeId = node.id;
          _selectedNodeId = node.id;
          _localPositions[node.id] = currentPos;
        });
      },
      onPanUpdate: (details) {
        if ((details.globalPosition - _dragStartPosition).distance > 5) {
          _isActuallyDragging = true;
        }
        setState(() {
          final delta = details.delta;
          final childrenIds = _getAllDescendants(node.id, controller.nodes);

          final parentPos =
              _localPositions[node.id] ?? _dragStartPositions[node.id]!;
          _localPositions[node.id] = parentPos.translate(delta.dx, delta.dy);

          for (var id in childrenIds) {
            final childPos = _localPositions[id] ?? _dragStartPositions[id];
            if (childPos != null) {
              _localPositions[id] = childPos.translate(delta.dx, delta.dy);
            }
          }
        });
      },
      onPanEnd: (_) {
        final finalPos = _localPositions[node.id]!;
        controller.moveSubtreeWithPositions(
            node.id, finalPos, _dragStartPositions); // 👈 Snapshot bheja
        setState(() {
          _draggingNodeId = null;
          _localPositions.clear();
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              if (!_isActuallyDragging) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FocusModeScreen(node: node)));
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: AnimatedScale(
                scale: isDragging ? 1.1 : (isSelected ? 1.05 : 1.0),
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? baseColor.withValues(alpha: 0.2)
                        : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? baseColor
                          : baseColor.withValues(alpha: 0.4),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                            color: baseColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        node.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (controller.getChildren(node.id).isNotEmpty)
            Positioned(
              bottom: -4,
              right: -4,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.toggleNodeCollapse(node.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: baseColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(node.isCollapsed ? Icons.add : Icons.remove,
                          size: 10, color: baseColor),
                      const SizedBox(width: 2),
                      Text('${controller.getChildren(node.id).length}',
                          style: TextStyle(
                              color: baseColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: -4,
            right: -4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).cardColor,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (context) => NodeDetailSheet(node: node),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: baseColor),
                ),
                child: Icon(Icons.edit, size: 12, color: baseColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAllDescendants(String nodeId, List<MindMapNode> allNodes) {
    List<String> result = [];
    List<String> queue = [nodeId];
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final kids = allNodes.where((n) => n.parentId == current).toList();
      for (var k in kids) {
        result.add(k.id);
        queue.add(k.id);
      }
    }
    return result;
  }
}

class _ConnectionPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final List<MindMapNode> visibleNodes;
  final Map<String, Offset> positions;
  final String? selectedId;
  final ThemeData theme;

  _ConnectionPainter(
      {required this.nodes,
      required this.visibleNodes,
      required this.positions,
      required this.selectedId,
      required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    Set<String> highlightedPath = {};
    if (selectedId != null) {
      String? currentId = selectedId;
      while (currentId != null) {
        highlightedPath.add(currentId);
        final node = nodes.firstWhere((n) => n.id == currentId,
            orElse: () => MindMapNode(id: '', title: '', parentId: null));
        currentId = node.parentId;
      }
    }

    for (var node in visibleNodes) {
      if (node.parentId == null ||
          positions[node.id] == null ||
          positions[node.parentId] == null) {
        continue;
      }
      final startPoint = positions[node.parentId]!;
      final endPoint = positions[node.id]!;
      bool isHighlighted = highlightedPath.contains(node.id) ||
          highlightedPath.contains(node.parentId);

      final linePaint = Paint()
        ..color = isHighlighted
            ? Color(int.parse(node.colorHex.replaceFirst('#', '0xFF')))
            : theme.dividerColor.withValues(alpha: 0.3)
        ..strokeWidth = isHighlighted ? 3.0 : 1.5
        ..style = PaintingStyle.stroke;

      final double angle =
          atan2(endPoint.dy - startPoint.dy, endPoint.dx - startPoint.dx);
      const double startRadius = 45.0, endRadius = 45.0;

      final startLine = Offset(startPoint.dx + startRadius * cos(angle),
          startPoint.dy + startRadius * sin(angle));
      final endLine = Offset(endPoint.dx - endRadius * cos(angle),
          endPoint.dy - endRadius * sin(angle));

      canvas.drawLine(startLine, endLine, linePaint);

      if (isHighlighted) {
        _drawArrowHead(canvas, endLine, angle, linePaint.color);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    const double arrowSize = 10.0;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(tip.dx - arrowSize * cos(angle - pi / 6),
        tip.dy - arrowSize * sin(angle - pi / 6));
    path.lineTo(tip.dx - arrowSize * cos(angle + pi / 6),
        tip.dy - arrowSize * sin(angle + pi / 6));
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) =>
      oldDelegate.selectedId != selectedId ||
      oldDelegate.positions != positions;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const double step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
