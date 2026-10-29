import 'package:flutter/material.dart';

class AppIconNode extends StatefulWidget {
  final String title;
  final Color baseColor;
  final IconData iconData;
  final int childCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onMenuSelected; // Optional for dashboard 3-dot menu

  const AppIconNode({
    super.key,
    required this.title,
    required this.baseColor,
    required this.iconData,
    required this.childCount,
    required this.onTap,
    required this.onEdit,
    this.onMenuSelected,
  });

  @override
  State<AppIconNode> createState() => _AppIconNodeState();
}

class _AppIconNodeState extends State<AppIconNode> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onEdit,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 👇 Icon Box with breathing glow
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 95, // 👈 1.25x Bada kiya
                    height: 95,
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                          widget.baseColor
                              .withValues(alpha: _isHovered ? 0.25 : 0.15),
                          theme.cardColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.baseColor
                            .withValues(alpha: _isHovered ? 0.8 : 0.4),
                        width: _isHovered ? 2 : 1.5,
                      ),
                      boxShadow: [
                        if (_isHovered)
                          BoxShadow(
                            color: widget.baseColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                      ],
                    ),
                    child: Center(
                      child: Icon(widget.iconData,
                          color: widget.baseColor, size: 32),
                    ),
                  ),

                  // 3-Dot Menu
                  if (widget.onMenuSelected != null)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: GestureDetector(
                        onTap: widget.onMenuSelected,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.2)),
                          ),
                          child: Icon(Icons.more_vert,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 14),
                        ),
                      ),
                    ),

                  // Child Count Badge
                  if (widget.childCount > 0)
                    Positioned(
                      bottom: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.baseColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: theme.scaffoldBackgroundColor, width: 2),
                        ),
                        child: Text(
                          '${widget.childCount}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              SizedBox(
                width: 85,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
