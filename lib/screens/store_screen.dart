import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 👈 Add kiya
import '../controllers/map_controller.dart';
import '../services/template_service.dart';
import '../models/node_model.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Digital Library',
              style:
                  TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFFE8D5B7),
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.black,
                unselectedLabelColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.5),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Official Books'),
                  Tab(text: 'Community'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _OfficialTemplatesTab(),
            _CommunityTemplatesTab(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 👇 TAB 1: Official Templates (Books)
// ==========================================
class _OfficialTemplatesTab extends StatefulWidget {
  const _OfficialTemplatesTab();

  @override
  State<_OfficialTemplatesTab> createState() => _OfficialTemplatesTabState();
}

class _OfficialTemplatesTabState extends State<_OfficialTemplatesTab> {
  String? _importingTemplateId;

  @override
  Widget build(BuildContext context) {
    final templates = TemplateService.getTemplates();
    final theme = Theme.of(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200, // Book width
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.65, // Tall ratio for book look
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final baseColor =
            Color(int.parse(template.colorHex.replaceFirst('#', '0xFF')));
        final isImporting = _importingTemplateId == template.id;

        return _buildBookCover(
          context: context,
          theme: theme,
          title: template.title,
          category: template.category,
          author: 'Official',
          baseColor: baseColor,
          isImporting: isImporting,
          icon: Icons.auto_stories,
          onTap: () {
            // 👈 Ab direct import nahi, menu khulega
            _showImportOptions(context, template.nodes, template.title);
          },
        );
      },
    );
  }
}

// ==========================================
// 👇 TAB 2: Community Templates (Books)
// ==========================================
class _CommunityTemplatesTab extends StatefulWidget {
  const _CommunityTemplatesTab();

  @override
  State<_CommunityTemplatesTab> createState() => _CommunityTemplatesTabState();
}

class _CommunityTemplatesTabState extends State<_CommunityTemplatesTab> {
  bool _isLoading = true;
  bool _hasError = false; // 👈 Naya
  List<DocumentSnapshot> _communityMaps = [];
  String? _importingMapId;

  @override
  void initState() {
    super.initState();
    _fetchCommunityMaps();
  }

  Future<void> _fetchCommunityMaps() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shared_templates')
          .orderBy('createdAt', descending: true)
          .get();
      if (mounted) {
        setState(() {
          _communityMaps = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // 👈 Ab red box nahi aayega, bas ek clean state dikhegi
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // 👈 NAYA: Error ya Login prompt state
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('Unable to load community books.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchCommunityMaps,
              child: const Text('Try Again',
                  style: TextStyle(color: Color(0xFFE8D5B7))),
            )
          ],
        ),
      );
    }

    if (_communityMaps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('No community books published yet.',
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCommunityMaps,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.65,
        ),
        itemCount: _communityMaps.length,
        itemBuilder: (context, index) {
          final doc = _communityMaps[index];
          final data = doc.data() as Map<String, dynamic>;
          final docId = doc.id;

          final title = data['title'] ?? 'Untitled';
          final author = data['authorEmail'] ?? 'Unknown User';
          final nodesJson = data['nodes'] as List<dynamic>? ?? [];
          final isImporting = _importingMapId == docId;

          return _buildBookCover(
            context: context,
            theme: theme,
            title: title,
            category: 'Community',
            author: author.split('@').first, // Just show first part of email
            baseColor: const Color(0xFF7B9EA8), // Blueish for community
            isImporting: isImporting,
            icon: Icons.people,
            onTap: () {
              try {
                final List<MindMapNode> nodes = nodesJson
                    .map((e) =>
                        MindMapNode.fromJson(Map<String, dynamic>.from(e)))
                    .toList();
                // 👈 Ab direct import nahi, menu khulega
                _showImportOptions(context, nodes, title);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('❌ Error: Invalid template format'),
                      backgroundColor: Colors.redAccent),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 👇 Helper Widget: 3D Book Cover
// ==========================================
Widget _buildBookCover({
  required BuildContext context,
  required ThemeData theme,
  required String title,
  required String category,
  required String author,
  required Color baseColor,
  required bool isImporting,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: isImporting ? null : onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(6, 6), // 3D shadow dropping down-right
          )
        ],
      ),
      child: Row(
        children: [
          // 👇 Book Spine (Left dark part)
          Container(
            width: 14,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3), // Dark spine effect
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ),
          // 👇 Book Front Cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    baseColor.withValues(alpha: 0.9),
                    Color.alphaBlend(Colors.black.withValues(alpha: 0.5),
                        baseColor), // Darker bottom right
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon,
                          color: Colors.white.withValues(alpha: 0.8), size: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Book Title
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Book Author / Bottom Info
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white54, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          author,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Read / Import Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: isImporting
                        ? const Center(
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white)))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Add to...', // 👈 Naya Text
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 👈 NAYA: Global Method taaki dono tabs (Official & Community) isko use kar sakein
void _showImportOptions(
    BuildContext context, List<MindMapNode> nodes, String title) {
  final theme = Theme.of(context);
  final controller = Provider.of<MapController>(context, listen: false);
  final folders = controller.getChildren(null);

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.cardColor,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Import "$title"',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // Option 1: Dashboard (Root)
            ListTile(
              leading:
                  Icon(Icons.home_outlined, color: theme.colorScheme.primary),
              title: Text('Add to Dashboard (Root)',
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () async {
                Navigator.pop(ctx);
                await controller.importTemplate(nodes);
                if (context.mounted) Navigator.pop(context);
              },
            ),

            // Option 2: Inside a Folder (Parent)
            if (folders.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Add inside an existing folder:',
                    style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12)),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (c, i) {
                    final folder = folders[i];
                    return ListTile(
                      leading: Icon(Icons.folder_outlined,
                          color: Color(int.parse(
                              folder.colorHex.replaceFirst('#', '0xFF')))),
                      title: Text(folder.title,
                          style: TextStyle(color: theme.colorScheme.onSurface)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await controller.importTemplate(nodes,
                            targetParentId: folder.id);
                        // 👈 Yahan brackets {} add kar diye hain warning fix ke liye
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
