import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../widgets/mind_tree_widget.dart';
import 'workspace_screen.dart'; // Tree tap karne par us folder mein jane ke liye

class MindGardenScreen extends StatelessWidget {
  const MindGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    // Saare root folders (Subjects/Books) uthao
    final rootNodes = controller.getChildren(null);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Mind Forest',
          style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5),
        ),
      ),
      body: rootNodes.isEmpty
          ? Center(
              child: Text(
                'Plant your first thought to start a tree.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            )
          : Container(
              // Ek halka sa gradient background (Sky/Soil feel)
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Trees per row
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 30,
                  childAspectRatio: 0.8,
                ),
                itemCount: rootNodes.length,
                itemBuilder: (context, index) {
                  final root = rootNodes[index];

                  // Us tree ke andar ke saare study nodes count karo
                  final allDescendants = controller.getMapWithChildren(root.id);
                  final studyNodes =
                      allDescendants.where((n) => n.type == 'study').toList();
                  final masteredNodes =
                      studyNodes.where((n) => n.strength >= 100).length;

                  // Base color (Folder ka color)
                  final baseColor =
                      Color(int.parse(root.colorHex.replaceFirst('#', '0xFF')));

                  return GestureDetector(
                    onTap: () {
                      // Tap karne par us specific map mein le jao
                      controller.setActiveMap(root.id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WorkspaceScreen()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: baseColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tree Widget
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: MindTreeWidget(
                              masteredCount: masteredNodes,
                              themeColor: baseColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              root.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Progress Text
                          Text(
                            '$masteredNodes / ${studyNodes.length} Mastered',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
