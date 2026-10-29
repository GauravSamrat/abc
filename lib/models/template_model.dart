import 'node_model.dart';

class MapTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isPremium;
  final String colorHex;
  final List<MindMapNode> nodes;

  MapTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isPremium = false,
    required this.colorHex,
    required this.nodes,
  });
}
