import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import 'focus_mode_screen.dart';
import '../widgets/ai_fallback_sheet.dart'; // 👈 Add kiya

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<MindMapNode> _results = [];
  String _query = '';
  String _selectedFilter = 'ALL'; // ALL, TASK, STUDY, NOTE

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MapController>(context);
    final theme = Theme.of(context);

    // Filter Logic
    if (_query.trim().isNotEmpty) {
      _results = controller.searchNodes(_query);
      if (_selectedFilter != 'ALL') {
        _results = _results
            .where((n) => n.type.toLowerCase() == _selectedFilter.toLowerCase())
            .toList();
      }
    } else {
      _results = [];
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: _searchCtrl,
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search your mind...',
              hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.search,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 20),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters
          if (_query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: ['ALL', 'TASK', 'STUDY', 'NOTE'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter, style: const TextStyle(fontSize: 10)),
                      selected: isSelected,
                      onSelected: (val) =>
                          setState(() => _selectedFilter = filter),
                      selectedColor: theme.colorScheme.primary,
                      backgroundColor: theme.cardColor,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.scaffoldBackgroundColor
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : theme.dividerColor.withValues(alpha: 0.2)),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Results or Empty State
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            size: 80,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.05)),
                        const SizedBox(height: 16),
                        Text('What are you looking for?',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text('We couldn\'t find "$_query" in your maps.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(
                                  'No worries! You can easily create this using AI.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                      fontSize: 13)),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor:
                                      theme.scaffoldBackgroundColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Create with AI',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) =>
                                        AiFallbackSheet(topic: _query),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final node = _results[index];
                          final nodeColor = Color(int.parse(
                              node.colorHex.replaceFirst('#', '0xFF')));

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: nodeColor.withValues(alpha: 0.2)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              onTap: () {
                                // 👈 NAYA: Direct Focus Mode open karo
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FocusModeScreen(node: node)));
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: nodeColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle),
                                child: Icon(
                                  node.type == 'task'
                                      ? Icons.check_circle_outline
                                      : node.type == 'idea'
                                          ? Icons.lightbulb_outline
                                          : node.type == 'study'
                                              ? Icons.school_outlined
                                              : Icons.notes,
                                  color: nodeColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(node.title,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15)),
                              subtitle: node.notes.isNotEmpty
                                  ? Text(node.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                          fontSize: 12))
                                  : null,
                              trailing: Icon(Icons.arrow_forward_ios,
                                  size: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
