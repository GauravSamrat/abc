import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/node_model.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_storage_service.dart';

enum MindMapView {
  outline,
  swipe,
  tiles,
  board,
  table,
  radial,
  timeline,
  canvas
}

enum StorageMode { local, cloud }

class MapController extends ChangeNotifier {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseStorageService _cloudStorage = FirebaseStorageService();

  MindMapView _currentView = MindMapView.tiles; // 👈 Default Tiles
  MindMapView get currentView => _currentView;

  // final Set<MindMapView> _unlockedViews =
  //     MindMapView.values.toSet(); // Sab unlock

  // MindMapView? _newlyUnlockedView;
  // MindMapView? get newlyUnlockedView => _newlyUnlockedView;

  // void clearNewlyUnlockedView() {
  //   _newlyUnlockedView = null;
  // }
  // 👇 UI Reduction: Sirf basic views default unlock hain
  // 👇 TESTING MODE: Sabhi views ab unlock hain
  // 👈 NAYA: Outline hata diya kyunki woh ab Tiles hi dikha raha hai
  final Set<MindMapView> _unlockedViews = {
    MindMapView.tiles,
    MindMapView.board,
    MindMapView.table,
    MindMapView.radial,
    MindMapView.timeline,
    MindMapView.canvas,
  };

  StorageMode _storageMode = StorageMode.cloud;
  StorageMode get storageMode => _storageMode;

  String _themeMode = 'dark'; // 'light', 'dark', 'sepia', 'zen'
  String get themeMode => _themeMode;

  // 👇 NAYA: User Goal (Onboarding ke liye)
  String? _userGoal;
  String? get userGoal => _userGoal;

  void loadUserGoal() {
    final box = Hive.box('abcitta_box');
    _userGoal = box.get('user_goal', defaultValue: null);
    notifyListeners();
  }

  Future<void> setUserGoal(String goal) async {
    _userGoal = goal;
    final box = Hive.box('abcitta_box');
    await box.put('user_goal', goal);
    notifyListeners();
  }

  // 👈 NAYA: Strength Filter ke liye variable
  int? _filterStrength;
  int? get filterStrength => _filterStrength;
  void setFilterStrength(int? val) {
    _filterStrength = val;
    notifyListeners();
  }

  // 👈 NAYA: Auto-play TTS setting
  bool _autoPlayTts = false;
  bool get autoPlayTts => _autoPlayTts;

  // 👈 NAYA: Global TTS Settings
  double _ttsVolume = 1.0;
  double _ttsPitch = 1.0;
  double _ttsRate = 1.0;
  String? _ttsVoiceName;

  double get ttsVolume => _ttsVolume;
  double get ttsPitch => _ttsPitch;
  double get ttsRate => _ttsRate;
  String? get ttsVoiceName => _ttsVoiceName;

  List<MindMapNode> _nodes = [];
  List<MindMapNode> get nodes => _nodes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _activeMapId;
  String? get activeMapId => _activeMapId;

  void setActiveMap(String? id) {
    _activeMapId = id;
    notifyListeners();
  }

  Future<void> loadNodes() async {
    _isLoading = true;
    loadStorageMode();
    loadTheme();
    loadAutoPlayTts();
    loadUserGoal(); // 👈 NAYA
    loadTtsSettings(); // 👈 Ye line add karein

    // 👇 Hive se locked views load karna band kar diya (Testing ke liye sab unlocked)
    // Agar future mein wapas chahiye, toh uncomment kar lena.
    /*
    final box = Hive.box('abcitta_box');
    final savedViews =
        box.get('unlocked_views', defaultValue: ['outline', 'swipe']) as List;
    _unlockedViews.clear();
    for (var v in savedViews) {
      _unlockedViews.add(MindMapView.values
          .firstWhere((e) => e.name == v, orElse: () => MindMapView.outline));
    }
    */

    notifyListeners();

    if (_storageMode == StorageMode.cloud) {
      _nodes = await _cloudStorage.getAllNodes();
    } else {
      _nodes = await _localStorage.getAllNodes();
    }

    if (_nodes.isEmpty) {
      await _seedDefaultWorkspaces();
    }

    _resetDailyRoutines();
    _applyMemoryDecay(); // 👈 NAYA: 21-Day Decay Rule
    _isLoading = false;
    notifyListeners();
  }

  // 👈 NAYA: Default Workspaces create karne ke liye
  Future<void> _seedDefaultWorkspaces() async {
    const purple = '#9C89B8';

    // 👈 NAYA: Sirf 1 folder seed karo taaki naya user overwhelm na ho
    final defaults = [
      {'title': 'My First Map', 'color': purple},
    ];

    for (var folder in defaults) {
      final rootId =
          'root_${folder['title']}_${DateTime.now().millisecondsSinceEpoch}';
      _nodes.add(MindMapNode(
        id: rootId,
        title: folder['title']!,
        parentId: null,
        colorHex: folder['color']!,
      ));

      // 👇 Kuch folders ke andar default nodes daal dete hain
      if (folder['title'] == 'Study') {
        _nodes.add(MindMapNode(
            id: '${rootId}_c1',
            title: 'Class 10',
            parentId: rootId,
            colorHex: folder['color']!));
        _nodes.add(MindMapNode(
            id: '${rootId}_c2',
            title: 'Class 12',
            parentId: rootId,
            colorHex: folder['color']!));
      } else if (folder['title'] == 'Tasks') {
        _nodes.add(MindMapNode(
            id: '${rootId}_c1',
            title: 'Today\'s Tasks',
            parentId: rootId,
            colorHex: folder['color']!));
        _nodes.add(MindMapNode(
            id: '${rootId}_c2',
            title: 'Tomorrow',
            parentId: rootId,
            colorHex: folder['color']!));
      } else if (folder['title'] == 'Money') {
        _nodes.add(MindMapNode(
            id: '${rootId}_c1',
            title: 'Budget',
            parentId: rootId,
            colorHex: folder['color']!));
        _nodes.add(MindMapNode(
            id: '${rootId}_c2',
            title: 'Investments',
            parentId: rootId,
            colorHex: folder['color']!));
      }
    }

    await _saveCurrentState();
  }

  Future<void> _saveCurrentState() async {
    if (_storageMode == StorageMode.cloud) {
      await _cloudStorage.saveNodes(_nodes);
    } else {
      await _localStorage.saveNodes(_nodes);
    }
  }

  void loadStorageMode() {
    final box = Hive.box('abcitta_box');
    final modeStr = box.get('storage_mode', defaultValue: 'cloud');
    _storageMode = modeStr == 'cloud' ? StorageMode.cloud : StorageMode.local;

    // 👇 Guest forced to local storage
    if (FirebaseAuth.instance.currentUser == null) {
      _storageMode = StorageMode.local;
    }
    notifyListeners();
  }

  void loadTheme() {
    final box = Hive.box('abcitta_box');
    _themeMode = box.get('theme_mode', defaultValue: 'dark');
    notifyListeners();
  }

  void loadAutoPlayTts() {
    final box = Hive.box('abcitta_box');
    _autoPlayTts = box.get('auto_play_tts', defaultValue: false);
    notifyListeners();
  }

  Future<void> setAutoPlayTts(bool val) async {
    _autoPlayTts = val;
    final box = Hive.box('abcitta_box');
    await box.put('auto_play_tts', val);
    notifyListeners();
  }

  void loadTtsSettings() {
    final box = Hive.box('abcitta_box');
    _ttsVolume = box.get('tts_volume', defaultValue: 1.0);
    _ttsPitch = box.get('tts_pitch', defaultValue: 1.0);
    _ttsRate = box.get('tts_rate', defaultValue: 1.0);
    _ttsVoiceName = box.get('tts_voice_name', defaultValue: null);
    notifyListeners();
  }

  Future<void> setTtsSettings(
      {double? volume, double? pitch, double? rate, String? voiceName}) async {
    final box = Hive.box('abcitta_box');
    if (volume != null) {
      _ttsVolume = volume;
      await box.put('tts_volume', volume);
    }
    if (pitch != null) {
      _ttsPitch = pitch;
      await box.put('tts_pitch', pitch);
    }
    if (rate != null) {
      _ttsRate = rate;
      await box.put('tts_rate', rate);
    }
    if (voiceName != null) {
      _ttsVoiceName = voiceName;
      await box.put('tts_voice_name', voiceName);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final box = Hive.box('abcitta_box');
    await box.put('theme_mode', mode);
    notifyListeners();
  }

  Future<void> toggleStorageMode(bool isCloud) async {
    _storageMode = isCloud ? StorageMode.cloud : StorageMode.local;
    final box = Hive.box('abcitta_box');
    await box.put('storage_mode', _storageMode.name);
    await loadNodes();
  }

  bool isViewUnlocked(MindMapView view) => _unlockedViews.contains(view);

  void changeView(MindMapView view) {
    _currentView = view;
    notifyListeners();
  }

  // 👈 YAHAN SORTING LOGIC ADD KI HAI
  List<MindMapNode> getChildren(String? parentId) {
    final children = _nodes.where((n) => n.parentId == parentId).toList();
    children.sort((a, b) => a.order.compareTo(b.order));
    return children;
  }

  // 👈 NAYA: Canvas ke liye recursive visible nodes nikalna
  List<MindMapNode> getVisibleNodes(String? parentId) {
    final visible = <MindMapNode>[];

    void traverse(String? pid) {
      final children = getChildren(pid);
      for (var c in children) {
        visible.add(c);
        if (!c.isCollapsed) {
          traverse(c.id);
        }
      }
    }

    traverse(parentId);
    return visible;
  }

  // 👈 NAYA: Drag & Drop Reordering
  Future<void> reorderNodes(
      String? parentId, int oldIndex, int newIndex) async {
    final children = getChildren(parentId);
    if (oldIndex < newIndex) newIndex -= 1;

    final movedNode = children[oldIndex];

    for (int i = 0; i < children.length; i++) {
      if (i == newIndex) {
        movedNode.order = i;
      } else if (i > newIndex && i <= oldIndex) {
        children[i].order += 1;
      } else if (i < newIndex && i >= oldIndex) {
        children[i].order -= 1;
      }
    }

    notifyListeners();
    await _saveCurrentState();
  }

  // 👈 NAYA: Duplicate Node
  Future<void> duplicateNode(String nodeId) async {
    final nodeToDuplicate = _nodes.firstWhere((n) => n.id == nodeId);
    final newId = 'dup_${DateTime.now().millisecondsSinceEpoch}';

    final newNode = MindMapNode(
      id: newId,
      title: '${nodeToDuplicate.title} (Copy)',
      parentId: nodeToDuplicate.parentId,
      colorHex: nodeToDuplicate.colorHex,
      notes: nodeToDuplicate.notes,
      type: nodeToDuplicate.type,
      links: List.from(nodeToDuplicate.links),
      order: nodeToDuplicate.order + 1,
    );

    _nodes.add(newNode);
    notifyListeners();
    await _saveCurrentState();
  }

  // 👈 NAYA: Share ke waqt pura tree nikalne ke liye
  List<MindMapNode> getMapWithChildren(String rootNodeId) {
    List<MindMapNode> result = [];
    List<String> idsToProcess = [rootNodeId];

    while (idsToProcess.isNotEmpty) {
      String currentId = idsToProcess.removeAt(0);
      final node = _nodes.firstWhere((n) => n.id == currentId,
          orElse: () => throw Exception("Not found"));
      result.add(node);

      final children = getChildren(currentId);
      idsToProcess.addAll(children.map((c) => c.id).toList());
    }
    return result;
  }

  // 👈 NAYA: Optional 'title' parameter add kiya
  Future<void> addChildNode(String parentId,
      {String title = 'New Idea'}) async {
    final siblings = getChildren(parentId);
    final newNode = MindMapNode(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      parentId: parentId,
      order: siblings.length, // Naya node sabse niche aayega
    );
    _nodes.add(newNode);
    notifyListeners();
    await _saveCurrentState();
    _checkUnlocks();
  }

  Future<void> addRootNode(String title) async {
    final roots = getChildren(null);
    final newNode = MindMapNode(
      id: 'root_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      parentId: null,
      order: roots.length,
    );
    _nodes.add(newNode);
    notifyListeners();
    await _saveCurrentState();
  }

  Future<void> renameNode(String nodeId, String newTitle) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].title = newTitle;
      notifyListeners();
      await _saveCurrentState();
    }
  }

  Future<void> deleteNode(String nodeId) async {
    List<String> idsToDelete = [nodeId];
    bool foundMore = true;
    while (foundMore) {
      foundMore = false;
      for (var node in _nodes) {
        if (node.parentId != null &&
            idsToDelete.contains(node.parentId) &&
            !idsToDelete.contains(node.id)) {
          idsToDelete.add(node.id);
          foundMore = true;
        }
      }
    }
    _nodes.removeWhere((n) => idsToDelete.contains(n.id));
    notifyListeners();
    await _saveCurrentState();
  }

  Future<void> updateNodeDetails(
    String nodeId, {
    String? title,
    String? notes,
    String? colorHex,
    String? type,
    String? dueDate,
    List<Map<String, String>>? links,
    List<MediaItem>? media,
    List<int>? routineDays,
    String? routineTime,
    String? tileSize,
    Map<String, dynamic>? interactiveData, // 👈 NAYA
  }) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      final node = _nodes[index];
      if (title != null) node.title = title;
      if (notes != null) node.notes = notes;
      if (colorHex != null) node.colorHex = colorHex;
      if (type != null) node.type = type;
      if (dueDate != null) node.dueDate = dueDate;
      if (links != null) node.links = links;
      if (media != null) {
        node.media = media;
      }
      if (routineDays != null) {
        node.routineDays = routineDays;
      }
      if (routineTime != null) {
        node.routineTime = routineTime;
      }
      if (tileSize != null) {
        node.tileSize = tileSize;
      }
      if (interactiveData != null) {
        node.interactiveData = interactiveData;
      } // 👈 NAYA

      notifyListeners();
      await _saveCurrentState();
    }
  }

  Future<bool> updateNodeParent(String nodeId, String? newParentId) async {
    if (nodeId == newParentId) return false;

    bool isDescendant(String potentialParentId, String targetNodeId) {
      String? currentId = potentialParentId;
      while (currentId != null) {
        if (currentId == targetNodeId) return true;
        final parent = _nodes.where((n) => n.id == currentId).firstOrNull;
        currentId = parent?.parentId;
      }
      return false;
    }

    if (newParentId != null && isDescendant(newParentId, nodeId)) {
      return false;
    }

    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].parentId = newParentId;
      _nodes[index].order =
          getChildren(newParentId).length; // Naya parent, sabse aakhri mein
      notifyListeners();
      await _saveCurrentState();
      return true;
    }
    return false;
  }

  Future<void> toggleNodeCompletion(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].isCompleted = !_nodes[index].isCompleted;
      if (_nodes[index].isCompleted) {
        _nodes[index].lastCompletedDate =
            DateTime.now().toIso8601String().split('T')[0];
      } else {
        _nodes[index].lastCompletedDate = null;
      }
      notifyListeners();
      await _saveCurrentState();
    }
  }

  Future<void> toggleNodeCollapse(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].isCollapsed = !_nodes[index].isCollapsed;
      notifyListeners();
      await _saveCurrentState();
    }
  }

  Future<void> updateNodePosition(
      String nodeId, double newX, double newY) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].x = newX;
      _nodes[index].y = newY;
      notifyListeners();
      await _saveCurrentState();
    }
  }

  // 👈 NAYA: Drag karte waqt sahi position save karne ke liye
  Future<void> moveSubtreeWithPositions(String nodeId, Offset newPos,
      Map<String, Offset> currentPositions) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index == -1) return;

    final currentX = currentPositions[nodeId]?.dx ?? _nodes[index].x;
    final currentY = currentPositions[nodeId]?.dy ?? _nodes[index].y;

    final deltaX = newPos.dx - currentX;
    final deltaY = newPos.dy - currentY;

    if (deltaX == 0 && deltaY == 0) return;

    // 1. Update parent absolute position
    _nodes[index].x = newPos.dx;
    _nodes[index].y = newPos.dy;

    // 2. Find all descendants
    List<String> descendants = [nodeId];
    bool foundMore = true;
    while (foundMore) {
      foundMore = false;
      for (var node in _nodes) {
        if (node.parentId != null &&
            descendants.contains(node.parentId) &&
            !descendants.contains(node.id)) {
          descendants.add(node.id);
          foundMore = true;
        }
      }
    }

    // 3. Update descendants by same delta
    for (var id in descendants) {
      if (id == nodeId) continue;
      final childIndex = _nodes.indexWhere((n) => n.id == id);
      if (childIndex != -1) {
        final childCurrentX = currentPositions[id]?.dx ?? _nodes[childIndex].x;
        final childCurrentY = currentPositions[id]?.dy ?? _nodes[childIndex].y;
        _nodes[childIndex].x = childCurrentX + deltaX;
        _nodes[childIndex].y = childCurrentY + deltaY;
      }
    }

    notifyListeners();
    await _saveCurrentState();
  }

  // 👈 NAYA: Parent ko drag karne par pure subtree ko move karna
  Future<void> moveSubtree(String nodeId, double deltaX, double deltaY) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index == -1) return;

    // 1. Move the parent
    _nodes[index].x += deltaX;
    _nodes[index].y += deltaY;

    // 2. Find all descendants (children, grandchildren...)
    List<String> descendants = [nodeId];
    bool foundMore = true;
    while (foundMore) {
      foundMore = false;
      for (var node in _nodes) {
        if (node.parentId != null &&
            descendants.contains(node.parentId) &&
            !descendants.contains(node.id)) {
          descendants.add(node.id);
          foundMore = true;
        }
      }
    }

    // 3. Move all descendants by the same delta
    for (var id in descendants) {
      if (id == nodeId) continue;
      final childIndex = _nodes.indexWhere((n) => n.id == id);
      if (childIndex != -1) {
        _nodes[childIndex].x += deltaX;
        _nodes[childIndex].y += deltaY;
      }
    }

    notifyListeners();
    await _saveCurrentState();
  }

  Future<void> reviewNode(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      final node = _nodes[index];
      node.reviewCount += 1;
      node.strength = (node.strength + 34).clamp(0, 100);

      if (node.reviewCount >= 3 || node.strength >= 100) {
        node.strength = 100;
        node.isCompleted = true;
        // 👈 NAYA: Fast Mastery ke baad 7 din baad dobara dikhega
        node.dueDate =
            DateTime.now().add(const Duration(days: 7)).toIso8601String();
      } else {
        final hoursToAdd = node.reviewCount == 1 ? 4 : 24;
        node.dueDate =
            DateTime.now().add(Duration(hours: hoursToAdd)).toIso8601String();
      }

      node.lastReviewedAt = DateTime.now().toIso8601String();
      _cachedNeedsAttentionNodes = null;

      notifyListeners();
      await _saveCurrentState();
      _checkUnlocks();
    }
  }

  Future<void> addTimeSpent(String nodeId, int seconds) async {
    if (seconds <= 0) return;
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index].timeSpentSeconds += seconds;
      _cachedTopTimeNodes = null;

      // 👈 NAYA: 3-Minute Rule (Strength badhao)
      if (seconds >= 180 && _nodes[index].type == 'study') {
        _nodes[index].strength = (_nodes[index].strength + 5).clamp(0, 100);
        _nodes[index].lastReviewedAt = DateTime.now().toIso8601String();
      }

      await _logFocusSession(seconds);

      Future.microtask(() {
        notifyListeners();
      });
      await _saveCurrentState();
    }
  }

  Future<void> _logFocusSession(int seconds) async {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('focus_sessions', defaultValue: []);
    final List<Map<String, dynamic>> sessions =
        rawSessions.map((e) => Map<String, dynamic>.from(e)).toList();

    sessions.add({
      'date': DateTime.now().toIso8601String(),
      'seconds': seconds,
    });

    await box.put('focus_sessions', sessions);
  }

  int get focusStreak {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('focus_sessions', defaultValue: []);
    final List<String> dates =
        rawSessions.map((e) => e['date'] as String).toList();
    return _calculateStreak(dates);
  }

  int get meditationStreak {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('meditation_sessions', defaultValue: []);
    final List<String> dates =
        rawSessions.map((e) => e['date'] as String).toList();
    return _calculateStreak(dates);
  }

  int _calculateStreak(List<String> isoDates) {
    if (isoDates.isEmpty) return 0;
    Set<String> uniqueDays = {};
    for (var iso in isoDates) {
      final dt = DateTime.parse(iso).toLocal();
      uniqueDays.add('${dt.year}-${dt.month}-${dt.day}');
    }

    int streak = 0;
    DateTime today = DateTime.now();

    String todayStr = '${today.year}-${today.month}-${today.day}';
    if (!uniqueDays.contains(todayStr)) {
      today = today.subtract(const Duration(days: 1));
    }

    while (true) {
      String checkStr = '${today.year}-${today.month}-${today.day}';
      if (uniqueDays.contains(checkStr)) {
        streak++;
        today = today.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  List<MindMapNode> searchNodes(String query) {
    if (query.trim().isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _nodes.where((n) {
      final titleMatch = n.title.toLowerCase().contains(lowerQuery);
      final notesMatch = n.notes.toLowerCase().contains(lowerQuery);
      return titleMatch || notesMatch;
    }).toList();
  }

  List<MindMapNode> get dueNodes {
    final now = DateTime.now();
    return _nodes.where((n) {
      if (n.dueDate == null || n.dueDate!.isEmpty) return false;
      final dueDate = DateTime.tryParse(n.dueDate!);
      if (dueDate == null) return false;
      return dueDate.isBefore(now) ||
          dueDate.isAtSameMomentAs(now) ||
          (dueDate.year == now.year &&
              dueDate.month == now.month &&
              dueDate.day == now.day);
    }).toList();
  }

  // 👈 NAYA: targetParentId add kiya taaki folder ke andar import ho sake
  Future<void> importTemplate(List<MindMapNode> templateNodes,
      {String? targetParentId}) async {
    final Map<String, String> idMap = {};
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    for (var node in templateNodes) {
      idMap[node.id] = '${node.id}_$timestamp';
    }

    for (var node in templateNodes) {
      // Agar node template ka root hai (parentId null), toh use targetParentId do
      final remappedParentId =
          node.parentId == null ? targetParentId : idMap[node.parentId];

      final newNode = MindMapNode(
        id: idMap[node.id]!,
        title: node.title,
        parentId: remappedParentId,
        colorHex: node.colorHex,
        notes: node.notes,
        type: node.type,
        x: node.x,
        y: node.y,
        links: node.links,
        order: node.order,
      );
      _nodes.add(newNode);
    }

    notifyListeners();
    await _saveCurrentState();
    _checkUnlocks();
  }

  Future<int> importNodesFromJson(List<MindMapNode> newNodes) async {
    final existingIds = _nodes.map((n) => n.id).toSet();
    final Map<String, String> idMap = {};
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Har imported node ke liye unique ID banao (collision pe suffix)
    for (var node in newNodes) {
      idMap[node.id] =
          existingIds.contains(node.id) ? '${node.id}_$timestamp' : node.id;
    }

    int addedCount = 0;
    for (var node in newNodes) {
      final newId = idMap[node.id]!;
      if (existingIds.contains(newId)) continue;

      // 2. parentId remap (agar imported parent hai to naya ID, warna as-is)
      final remappedParent = node.parentId != null
          ? (idMap[node.parentId] ?? node.parentId)
          : null;

      // 3. extraConnections ke targetId bhi remap karo
      final remappedConns = node.extraConnections.map((conn) {
        final targetId = conn['targetId'] as String?;
        if (targetId != null && idMap.containsKey(targetId)) {
          return {...conn, 'targetId': idMap[targetId]};
        }
        return conn;
      }).toList();

      // 4. Naya clone banao (original ko mutate mat karo)
      _nodes.add(MindMapNode(
        id: newId,
        title: node.title,
        parentId: remappedParent,
        colorHex: node.colorHex,
        isCollapsed: node.isCollapsed,
        notes: node.notes,
        type: node.type,
        dueDate: node.dueDate,
        isCompleted: node.isCompleted,
        x: node.x,
        y: node.y,
        strength: node.strength,
        reviewCount: node.reviewCount,
        lastReviewedAt: node.lastReviewedAt,
        timeSpentSeconds: node.timeSpentSeconds,
        links: node.links,
        media: node.media,
        order: node.order,
        routineDays: node.routineDays,
        tileSize: node.tileSize,
        extraConnections: remappedConns,
        lastCompletedDate: node.lastCompletedDate,
        routineTime: node.routineTime,
        interactiveData: node.interactiveData,
      ));
      addedCount++;
    }

    if (addedCount > 0) {
      notifyListeners();
      await _saveCurrentState();
    }
    return addedCount;
  }

  Future<void> saveMeditationSession(int seconds) async {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('meditation_sessions', defaultValue: []);
    final List<Map<String, dynamic>> sessions =
        rawSessions.map((e) => Map<String, dynamic>.from(e)).toList();

    sessions.add({
      'date': DateTime.now().toIso8601String(),
      'seconds': seconds,
    });

    await box.put('meditation_sessions', sessions);
    notifyListeners();
  }

  int getMeditationToday() {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('meditation_sessions', defaultValue: []);
    final now = DateTime.now();
    int total = 0;
    for (var s in rawSessions) {
      final dt = DateTime.parse(s['date']);
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        total += (s['seconds'] as num).toInt();
      }
    }
    return total;
  }

  int getMeditationThisWeek() {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('meditation_sessions', defaultValue: []);
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    int total = 0;
    for (var s in rawSessions) {
      final dt = DateTime.parse(s['date']);
      if (dt.isAfter(startOfWeekDate) || dt.isAtSameMomentAs(startOfWeekDate)) {
        total += (s['seconds'] as num).toInt();
      }
    }
    return total;
  }

  int getMeditationThisMonth() {
    final box = Hive.box('abcitta_box');
    final List<dynamic> rawSessions =
        box.get('meditation_sessions', defaultValue: []);
    final now = DateTime.now();
    int total = 0;
    for (var s in rawSessions) {
      final dt = DateTime.parse(s['date']);
      if (dt.year == now.year && dt.month == now.month) {
        total += (s['seconds'] as num).toInt();
      }
    }
    return total;
  }

  void _resetDailyRoutines() {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    bool changed = false;
    for (var node in _nodes) {
      if (node.routineDays.isNotEmpty && node.isCompleted) {
        if (node.lastCompletedDate != todayStr) {
          node.isCompleted = false;
          changed = true;
        }
      }
    }
    if (changed) _saveCurrentState();
  }

  List<MindMapNode> getScheduleForDate(DateTime date) {
    final dayOfWeek = date.weekday;
    final dateString = date.toIso8601String().split('T')[0];

    List<MindMapNode> schedule = _nodes.where((n) {
      if (n.routineDays.contains(dayOfWeek)) return true;
      if (n.dueDate != null && n.dueDate!.isNotEmpty) {
        final dueDate = DateTime.tryParse(n.dueDate!);
        if (dueDate != null) {
          final dueStr = dueDate.toIso8601String().split('T')[0];
          if (dueStr == dateString) return true;
        }
      }
      return false;
    }).toList();

    schedule.sort((a, b) {
      String timeA = a.dueDate ?? a.routineTime ?? '23:59';
      String timeB = b.dueDate ?? b.routineTime ?? '23:59';
      return timeA.compareTo(timeB);
    });
    return schedule;
  }

  List<MindMapNode> get todaysRoutineNodes {
    final today = DateTime.now().weekday;
    return _nodes.where((n) => n.routineDays.contains(today)).toList();
  }

  // 👇 NAYA: Phase 7 Analytics (With Caching)
  List<MindMapNode>? _cachedTopTimeNodes;
  List<MindMapNode>? _cachedNeedsAttentionNodes;

  // 1. Top 5 Nodes by Time Spent
  List<MindMapNode> get topTimeNodes {
    if (_cachedTopTimeNodes != null) return _cachedTopTimeNodes!;
    final list = _nodes.where((n) => n.timeSpentSeconds > 0).toList()
      ..sort((a, b) => b.timeSpentSeconds.compareTo(a.timeSpentSeconds));
    _cachedTopTimeNodes = list.take(5).toList();
    return _cachedTopTimeNodes!;
  }

  // 2. Nodes that need attention (No-Shame list)
  List<MindMapNode> get needsAttentionNodes {
    if (_cachedNeedsAttentionNodes != null) return _cachedNeedsAttentionNodes!;
    final list = _nodes
        .where((n) => n.type == 'study' && n.strength < 50)
        .toList()
      ..sort(
          (a, b) => a.strength.compareTo(b.strength)); // Lowest strength first
    _cachedNeedsAttentionNodes = list;
    return _cachedNeedsAttentionNodes!;
  }

  // 3. Strength Distribution (For the minimal bar chart)
  Map<String, int> get strengthDistribution {
    int s1 = 0, s2 = 0, s3 = 0, s4 = 0, s5 = 0;
    for (var n in _nodes.where((n) => n.type == 'study')) {
      if (n.strength <= 20) {
        s1++;
      } else if (n.strength <= 40) {
        s2++;
      } else if (n.strength <= 60) {
        s3++;
      } else if (n.strength <= 80) {
        s4++;
      } else {
        s5++;
      }
    }
    return {
      '0-20%': s1,
      '21-40%': s2,
      '41-60%': s3,
      '61-80%': s4,
      '81-100%': s5
    };
  }

  // 👇 Phase 7: Milestone-based Level System
  // 👇 NAYA: Mastered Nodes count (Level system)
  int get userProgressCount =>
      _nodes.where((n) => n.type == 'study' && n.strength >= 100).length;
  int get masteredNodesCount => userProgressCount;

  String get userLevelTitle {
    switch (userLevel) {
      case 5:
        return 'Master';
      case 4:
        return 'Scholar';
      case 3:
        return 'Learner';
      case 2:
        return 'Novice';
      default:
        return 'Seeker';
    }
  }

  int get userLevel {
    final c = userProgressCount;
    if (c >= 50) return 5;
    if (c >= 25) return 4;
    if (c >= 10) return 3;
    if (c >= 3) return 2; // 👈 3 nodes = Level 2 (Instant Dopamine)
    return 1;
  }

  int get userNextMilestone {
    final c = userProgressCount;
    if (c >= 50) return 50;
    if (c >= 25) return 50;
    if (c >= 10) return 25;
    if (c >= 3) return 10;
    return 3; // 👈 Level 1 to 2 needs 3 nodes
  }

  // 👇 NAYA: User ke Goal ke hisaab se Priority Node nikalna
  MindMapNode? get priorityNode {
    if (_nodes.isEmpty) return null;

    // Agar user ka koi goal set hai, toh us title se match karo
    if (_userGoal != null) {
      final match = _nodes
          .where((n) =>
              n.title.toLowerCase().contains(_userGoal!.toLowerCase()) &&
              n.parentId == null)
          .firstOrNull;
      if (match != null) return match;
    }

    // Warna sabse pehla root node return karo
    return _nodes.where((n) => n.parentId == null).firstOrNull;
  }

  // 👇 NAYA: Local data ko Cloud mein Merge karne ke liye
  Future<void> syncLocalToCloud() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      // 1. Local aur Cloud data fetch karo
      final localNodes = await _localStorage.getAllNodes();
      if (localNodes.isEmpty) return;

      final cloudNodes = await _cloudStorage.getAllNodes();
      final cloudIds = cloudNodes.map((n) => n.id).toSet();

      // 2. Sirf woh nodes cloud mein bhejo jo wahan nahi hain (ID clash avoid karne ke liye)
      final nodesToUpload = <MindMapNode>[];
      for (var local in localNodes) {
        if (!cloudIds.contains(local.id)) {
          nodesToUpload.add(local);
        }
      }

      // 3. Merge karke cloud pe save karo
      if (nodesToUpload.isNotEmpty) {
        final merged = [...cloudNodes, ...nodesToUpload];
        await _cloudStorage.saveNodes(merged);
      }

      // 4. Ab storage mode ko Cloud kar do
      _storageMode = StorageMode.cloud;
      final box = Hive.box('abcitta_box');
      await box.put('storage_mode', 'cloud');

      // 5. Cloud se fresh data load karo
      await loadNodes();
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  int getTotalNodes(String mapId) {
    // 👈 FIX: getMapWithChildren spelling theek ki
    final allNodes = getMapWithChildren(mapId);
    return allNodes.isNotEmpty ? allNodes.length - 1 : 0;
  }

  String getEstimatedTime(String mapId) {
    final total = getTotalNodes(mapId);
    if (total == 0) return '0 min';
    final minutes = total * 3; // 1 node = 3 minute
    if (minutes >= 60) {
      final hrs = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hrs}h ${mins}m' : '${hrs}h';
    }
    return '${minutes}min';
  }

  // 👇 NAYA: Onboarding State & Magic Seed Logic
  bool get hasCompletedOnboarding =>
      Hive.box('abcitta_box').get('onboarding_done', defaultValue: false);

  String get userRole =>
      Hive.box('abcitta_box').get('user_role', defaultValue: '');
  String get userFocus =>
      Hive.box('abcitta_box').get('user_focus', defaultValue: '');
  String get userInterest =>
      Hive.box('abcitta_box').get('user_interest', defaultValue: '');

  Future<void> completeOnboarding({
    required String role,
    required String focus,
    required String interest,
  }) async {
    final box = Hive.box('abcitta_box');
    await box.put('onboarding_done', true);
    await box.put('user_role', role);
    await box.put('user_focus', focus);
    await box.put('user_interest', interest);

    // 👇 MAGIC: Seed the personalized map!
    await _seedPersonalizedMap(interest);
    notifyListeners();
  }

  Future<void> _seedPersonalizedMap(String interest) async {
    // Agar already map hai (user ne dobara onboarding kiya toh), toh duplicate na banao
    if (_nodes.any((n) => n.title == interest && n.parentId == null)) return;

    final rootId = 'root_${interest}_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create Root Node (e.g., "Coding")
    _nodes.add(MindMapNode(
      id: rootId,
      title: interest,
      parentId: null,
      colorHex: '#9C89B8', // Purple theme
    ));

    // 2. Add Starter Nodes based on Interest
    List<String> starters = [];
    if (interest == 'Science') {
      starters = [
        'The Scientific Method',
        'Physics Basics',
        'Biology Fundamentals'
      ];
    } else if (interest == 'Maths')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Algebraic Thinking', 'Geometry Shapes', 'Problem Solving'];
    else if (interest == 'Coding')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Hello World', 'Variables & Logic', 'Build a Mini App'];
    else if (interest == 'History')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Ancient Civilizations', 'World Wars', 'Modern History'];
    else if (interest == 'Fitness')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Morning Stretch', 'Cardio Basics', 'Healthy Diet'];
    else if (interest == 'Habits')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Atomic Habits', 'Daily Routine', 'Mindfulness'];
    else if (interest == 'Psychology')
      // ignore: curly_braces_in_flow_control_structures
      starters = ['How the Brain Works', 'Cognitive Biases', 'Mental Models'];
    else
      // ignore: curly_braces_in_flow_control_structures
      starters = ['Introduction', 'Key Concepts', 'Practice'];

    int order = 0;
    for (var starter in starters) {
      _nodes.add(MindMapNode(
        id: 'node_${DateTime.now().millisecondsSinceEpoch}_$order',
        title: starter,
        parentId: rootId,
        type: 'study', // Taaki schedule mein dikhe
        colorHex: '#9C89B8',
        notes: 'This is a starter node for $starter. Add your notes here!',
        order: order++,
      ));
    }

    await _saveCurrentState();
  }

  // 👈 NAYA: 21-Day Memory Decay
  void _applyMemoryDecay() {
    bool changed = false;
    final now = DateTime.now();

    for (var node in _nodes) {
      if (node.type == 'study' &&
          node.lastReviewedAt != null &&
          node.strength > 0) {
        final lastReview = DateTime.tryParse(node.lastReviewedAt!);
        if (lastReview != null) {
          final daysSince = now.difference(lastReview).inDays;
          // Agar 21 din tak touch nahi kiya, toh strength kam karo
          if (daysSince >= 21 && !dueNodes.contains(node)) {
            node.strength = (node.strength - 30).clamp(0, 100);
            node.isCompleted = false;
            node.dueDate =
                now.toIso8601String(); // Wapas Review queue mein bhejo
            changed = true;
          }
        }
      }
    }
    if (changed) _saveCurrentState();
  }

  void _checkUnlocks() {
    bool changed = false;
    final level = userLevel;

    if (level >= 2) {
      if (!_unlockedViews.contains(MindMapView.tiles)) {
        _unlockedViews.add(MindMapView.tiles);
        changed = true;
      }
      if (!_unlockedViews.contains(MindMapView.board)) {
        _unlockedViews.add(MindMapView.board);
        changed = true;
      }
    }
    if (level >= 3) {
      if (!_unlockedViews.contains(MindMapView.table)) {
        _unlockedViews.add(MindMapView.table);
        changed = true;
      }
      if (!_unlockedViews.contains(MindMapView.timeline)) {
        _unlockedViews.add(MindMapView.timeline);
        changed = true;
      }
      if (!_unlockedViews.contains(MindMapView.radial)) {
        _unlockedViews.add(MindMapView.radial);
        changed = true;
      }
    }
    if (level >= 4) {
      if (!_unlockedViews.contains(MindMapView.canvas)) {
        _unlockedViews.add(MindMapView.canvas);
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }
}
