import 'package:hive/hive.dart';
import '../../models/node_model.dart';

class LocalStorageService {
  final Box _box = Hive.box('abcitta_box');

  Future<List<MindMapNode>> getAllNodes() async {
    final rawList = _box.get('nodes', defaultValue: []) as List;
    return rawList
        .map((e) => MindMapNode.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveNodes(List<MindMapNode> nodes) async {
    final jsonList = nodes.map((e) => e.toJson()).toList();
    await _box.put('nodes', jsonList);
  }
}
