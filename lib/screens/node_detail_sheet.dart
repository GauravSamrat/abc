// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controllers/map_controller.dart';
import '../models/node_model.dart';
import 'focus_mode_screen.dart';
import 'notes_editor_screen.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/firebase_storage_service.dart';

class NodeDetailSheet extends StatefulWidget {
  final MindMapNode node;
  const NodeDetailSheet({super.key, required this.node});

  @override
  State<NodeDetailSheet> createState() => _NodeDetailSheetState();
}

class _NodeDetailSheetState extends State<NodeDetailSheet> {
  late TextEditingController _titleCtrl;
  Color _selectedColor = Colors.blue;
  late String _selectedType;
  DateTime? _selectedDueDate;
  String? _selectedParentId;
  List<int> _selectedRoutineDays = [];
  List<Map<String, dynamic>> _extraConnections = [];
  late String _selectedTileSize;
  TimeOfDay? _selectedRoutineTime;
  bool _isSharing = false;
  String _notes = '';

  // Advanced toggle
  bool _showAdvanced = false;

  // Voice
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Interactive (QnA / Game)
  String _qnaQuestion = '';
  late TextEditingController _qnaQuestionCtrl;
  List<String> _qnaOptions = ['', '', '', ''];
  int _qnaCorrectIndex = 0;
  List<Map<String, String>> _gamePairs = [];
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.node.title);
    _qnaQuestionCtrl = TextEditingController(
        text: widget.node.interactiveData?['question'] ?? '');
    _notes = widget.node.notes;
    _selectedType = widget.node.type;
    _coverImageUrl = widget.node.coverImageUrl;

    if (widget.node.interactiveData != null) {
      _qnaQuestion = widget.node.interactiveData!['question'] ?? '';
      _qnaOptions = List<String>.from(
          widget.node.interactiveData!['options'] ?? ['', '', '', '']);
      _qnaCorrectIndex =
          widget.node.interactiveData!['correctAnswerIndex'] ?? 0;
      if (widget.node.interactiveData!['pairs'] != null) {
        _gamePairs = (widget.node.interactiveData!['pairs'] as List)
            .map((e) => Map<String, String>.from(e))
            .toList();
      }
    }

    _selectedDueDate = widget.node.dueDate != null
        ? DateTime.tryParse(widget.node.dueDate!)
        : null;
    _selectedParentId = widget.node.parentId;
    _selectedRoutineDays = List.from(widget.node.routineDays);
    _selectedTileSize = widget.node.tileSize;
    _extraConnections = List.from(widget.node.extraConnections);

    try {
      _selectedColor =
          Color(int.parse(widget.node.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      _selectedColor = Colors.blue;
    }

    if (widget.node.routineTime != null &&
        widget.node.routineTime!.isNotEmpty) {
      final parts = widget.node.routineTime!.split(':');
      _selectedRoutineTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _qnaQuestionCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final controller = Provider.of<MapController>(context, listen: false);

    final hexColor =
        '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    controller.updateNodeDetails(
      widget.node.id,
      title: _titleCtrl.text.trim(),
      notes: _notes,
      colorHex: hexColor,
      type: _selectedType,
      dueDate: _selectedDueDate?.toIso8601String(),
      routineDays: _selectedRoutineDays,
      tileSize: _selectedTileSize,
      routineTime: _selectedRoutineTime != null
          ? '${_selectedRoutineTime!.hour.toString().padLeft(2, '0')}:${_selectedRoutineTime!.minute.toString().padLeft(2, '0')}'
          : null,
      interactiveData: _selectedType == 'qna'
          ? {
              'question': _qnaQuestion,
              'options': _qnaOptions,
              'correctAnswerIndex': _qnaCorrectIndex
            }
          : _selectedType == 'game'
              ? {'pairs': _gamePairs}
              : null,
    );

    // Cover image save karo (temporary solution)
    widget.node.coverImageUrl = _coverImageUrl;

    widget.node.extraConnections = _extraConnections;
    if (_selectedParentId != widget.node.parentId) {
      controller.updateNodeParent(widget.node.id, _selectedParentId);
    }
    Navigator.pop(context);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        // ignore: avoid_print
        onStatus: (val) => print('onStatus: $val'),
        // ignore: avoid_print
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _notes = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _openNotesEditor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesEditorScreen(
          initialText: _notes,
          title: _titleCtrl.text,
        ),
      ),
    );
    if (result != null) {
      setState(() => _notes = result);
    }
  }

  Future<void> _shareToCommunity() async {
    final controller = Provider.of<MapController>(context, listen: false);

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final descCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Share to Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Publish "${_titleCtrl.text}" to the public store?',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Share Now')),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isSharing = true);

    try {
      final allNodes = controller.getMapWithChildren(widget.node.id);
      final storageService = FirebaseStorageService();
      final result = await storageService.shareTemplateToCloud(
        title: _titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        nodes: allNodes,
      );

      if (!mounted) return;
      setState(() => _isSharing = false);

      if (result == "Success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Map shared to Community Store successfully!'),
            backgroundColor: Colors.green));
      } else if (result == "Duplicate") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('⚠️ You already shared a map with this title.'),
            backgroundColor: Colors.orange));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ Error: $result'),
            backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSharing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ Failed to share: $e'),
          backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 12,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),

              // 👇 TOP ACTIONS (Close & Delete on Left, Preview, Share, Copy on Right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close,
                            color: textColor.withValues(alpha: 0.5)),
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            size: 22),
                        tooltip: 'Delete Node',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: theme.cardColor,
                              title: const Text('Delete Node?'),
                              content: const Text(
                                  'This node and all its children will be deleted permanently.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.grey))),
                                TextButton(
                                  onPressed: () {
                                    Provider.of<MapController>(context,
                                            listen: false)
                                        .deleteNode(widget.node.id);
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Delete',
                                      style:
                                          TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_red_eye_outlined,
                            color: theme.colorScheme.primary),
                        tooltip: 'Preview',
                        onPressed: () {
                          _saveChanges();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FocusModeScreen(node: widget.node)));
                        },
                      ),
                      if (_isSharing)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.share_outlined,
                              color: Colors.orangeAccent, size: 22),
                          tooltip: 'Share',
                          onPressed: _shareToCommunity,
                        ),
                      IconButton(
                        icon: const Icon(Icons.copy,
                            color: Colors.blueAccent, size: 20),
                        tooltip: 'Duplicate',
                        onPressed: () {
                          Provider.of<MapController>(context, listen: false)
                              .duplicateNode(widget.node.id);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),

              // 1. SPACIOUS TITLE
              TextField(
                controller: _titleCtrl,
                style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.2),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.2)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 20),

              // 2. NOTES CANVAS (Better Contrast & Border)
              GestureDetector(
                onTap: _openNotesEditor,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.dividerColor
                            .withValues(alpha: 0.2)), // 👈 Subtle border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes,
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Notes',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _notes.isEmpty
                            ? 'Tap here to start writing your thoughts...'
                            : _notes,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _notes.isEmpty
                                ? Colors.grey
                                : textColor.withValues(alpha: 0.9),
                            fontSize: 15,
                            height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _listen,
                            child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening
                                    ? Colors.redAccent
                                    : Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.edit, color: Colors.grey, size: 18),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. SMART TYPE SELECTOR
              Text('What is this?',
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildTypePill('note', '📝 Note', theme),
                  _buildTypePill('task', '✅ Task', theme),
                  _buildTypePill('study', '📚 Study', theme),
                  _buildTypePill('game', '🎮 Game', theme),
                ],
              ),

              // 👇 STUDY KE ANDAR QUIZ KA OPTION
              if (_selectedType == 'study' || _selectedType == 'qna') ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Turn into Quiz (Q&A)',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  subtitle: const Text('Play interactive quiz in Focus Mode',
                      style: TextStyle(fontSize: 12)),
                  activeThumbColor: theme.colorScheme.primary,
                  value: _selectedType == 'qna',
                  onChanged: (val) {
                    setState(() => _selectedType = val ? 'qna' : 'study');
                  },
                ),
              ],

              // 👇 QUIZ BUILDER
              if (_selectedType == 'qna') ...[
                const SizedBox(height: 16),
                _buildSectionHeader(theme, 'QUIZ DETAILS'),
                const SizedBox(height: 12),
                TextField(
                  controller: _qnaQuestionCtrl,
                  onChanged: (v) => _qnaQuestion = v,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your question here...',
                    filled: true,
                    fillColor:
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          // ignore: deprecated_member_use
                          groupValue: _qnaCorrectIndex,
                          activeColor: theme.colorScheme.primary,
                          // ignore: deprecated_member_use
                          onChanged: (val) =>
                              setState(() => _qnaCorrectIndex = val!),
                        ),
                        Expanded(
                          child: TextFormField(
                            initialValue: _qnaOptions[index],
                            onChanged: (v) => _qnaOptions[index] = v,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Option ${index + 1}',
                              filled: true,
                              fillColor: theme.scaffoldBackgroundColor
                                  .withValues(alpha: 0.5),
                              isDense: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Text('Select the radio button for the correct answer.',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontStyle: FontStyle.italic)),
              ],

              // 👇 GAME BUILDER
              if (_selectedType == 'game') ...[
                const SizedBox(height: 16),
                _buildSectionHeader(theme, 'MEMORY GAME PAIRS'),
                const SizedBox(height: 12),
                ..._gamePairs.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['front'],
                            onChanged: (v) => _gamePairs[idx]['front'] = v,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                                hintText: 'Front (e.g. H2O)',
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor
                                    .withValues(alpha: 0.5),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: entry.value['back'],
                            onChanged: (v) => _gamePairs[idx]['back'] = v,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                                hintText: 'Back (e.g. Water)',
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor
                                    .withValues(alpha: 0.5),
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent, size: 20),
                          onPressed: () =>
                              setState(() => _gamePairs.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _gamePairs.add({'front': '', 'back': ''})),
                  icon: Icon(Icons.add,
                      size: 16, color: theme.colorScheme.primary),
                  label: Text('Add Pair',
                      style: TextStyle(color: theme.colorScheme.primary)),
                ),
              ],

              const SizedBox(height: 32),

              // 4. ADVANCED SETTINGS TOGGLE
              InkWell(
                onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune,
                              size: 20,
                              color: textColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 12),
                          Text('Advanced Settings',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Icon(
                          _showAdvanced ? Icons.expand_less : Icons.expand_more,
                          color: textColor.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),

              // 👇 ADVANCED SETTINGS CONTENT
              if (_showAdvanced) ...[
                const SizedBox(height: 24),

                // Schedule / Routine
                _buildSectionHeader(theme, 'SCHEDULE & ROUTINE'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 5)));
                          if (pickedDate != null && context.mounted) {
                            final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    _selectedDueDate ?? DateTime.now()));
                            if (pickedTime != null) {
                              setState(() => _selectedDueDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute));
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event,
                                  size: 18,
                                  color: _selectedDueDate != null
                                      ? theme.colorScheme.primary
                                      : Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedDueDate == null
                                      ? 'Due Date'
                                      : DateFormat('MMM dd, hh:mm a')
                                          .format(_selectedDueDate!),
                                  style: TextStyle(
                                      color: _selectedDueDate == null
                                          ? Colors.grey
                                          : textColor,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedDueDate != null)
                                GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedDueDate = null),
                                    child: const Icon(Icons.close,
                                        color: Colors.redAccent, size: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Routine Days
                if (_selectedType == 'task' ||
                    _selectedType == 'study' ||
                    _selectedType == 'routine') ...[
                  Wrap(
                    spacing: 8,
                    children: <Map<String, dynamic>>[
                      {'day': 1, 'label': 'M'},
                      {'day': 2, 'label': 'T'},
                      {'day': 3, 'label': 'W'},
                      {'day': 4, 'label': 'T'},
                      {'day': 5, 'label': 'F'},
                      {'day': 6, 'label': 'S'},
                      {'day': 7, 'label': 'S'},
                    ].map((d) {
                      final int day = d['day'] as int;
                      final String label = d['label'] as String;
                      final isSelected = _selectedRoutineDays.contains(day);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) {
                            _selectedRoutineDays.remove(day);
                          } else {
                            _selectedRoutineDays.add(day);
                          }
                        }),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                              child: Text(label,
                                  style: TextStyle(
                                      color: isSelected
                                          ? theme.scaffoldBackgroundColor
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedRoutineTime ?? TimeOfDay.now());
                      if (picked != null)
                        setState(() => _selectedRoutineTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                              _selectedRoutineTime == null
                                  ? 'Set Routine Time'
                                  : _selectedRoutineTime!.format(context),
                              style: TextStyle(
                                  color: _selectedRoutineTime == null
                                      ? Colors.grey
                                      : textColor,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Color
                _buildSectionHeader(theme, 'COLOR THEME'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: theme.cardColor,
                        title: const Text('Pick a Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) =>
                                setState(() => _selectedColor = color),
                            pickerAreaHeightPercent: 0.7,
                            enableAlpha: false,
                            displayThumbColor: true,
                            paletteType: PaletteType.hsvWithHue,
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Done'))
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                color: _selectedColor, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Text('Tap to pick custom color',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        const Icon(Icons.colorize,
                            size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cover Image
                _buildSectionHeader(theme, 'COVER IMAGE URL'),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _coverImageUrl),
                  onChanged: (val) => _coverImageUrl = val,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'https://...',
                    filled: true,
                    fillColor:
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),

                // Parent Node
                _buildSectionHeader(theme, 'PARENT NODE'),
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final allNodes = Provider.of<MapController>(context).nodes;
                  final validParents =
                      allNodes.where((n) => n.id != widget.node.id).toList();
                  if (!validParents.any((n) => n.id == _selectedParentId))
                    _selectedParentId = null;

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedParentId,
                    dropdownColor: theme.cardColor,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('None (Root Level)')),
                      ...validParents.map((n) => DropdownMenuItem<String>(
                          value: n.id,
                          child:
                              Text(n.title, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (val) => setState(() => _selectedParentId = val),
                  );
                }),
                const SizedBox(height: 24),

                // Tile Size
                _buildSectionHeader(theme, 'TILE SIZE (GRID)'),
                const SizedBox(height: 12),
                Row(
                  children: ['small', 'medium', 'large'].map((size) {
                    final isSelected = (_selectedTileSize == size);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTileSize = size),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(size.toUpperCase(),
                            style: TextStyle(
                                color: isSelected
                                    ? theme.scaffoldBackgroundColor
                                    : textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Extra Connections
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(theme, 'EXTRA CONNECTIONS'),
                    TextButton.icon(
                      onPressed: () => _showAddConnectionDialog(context),
                      icon: Icon(Icons.add_link,
                          size: 16, color: theme.colorScheme.primary),
                      label: Text('Connect',
                          style: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 12)),
                    ),
                  ],
                ),
                if (_extraConnections.isNotEmpty)
                  ..._extraConnections.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var conn = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          const Icon(Icons.double_arrow,
                              size: 16, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${conn['label'] ?? 'Link'} ➔ ${Provider.of<MapController>(context, listen: false).nodes.firstWhere((n) => n.id == conn['targetId'], orElse: () => MindMapNode(id: '', title: 'Unknown')).title}',
                              style: TextStyle(color: textColor, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent, size: 18),
                              onPressed: () => setState(
                                  () => _extraConnections.removeAt(idx)))
                        ],
                      ),
                    );
                  }).toList(),
              ],

              const SizedBox(height: 40),

              // 👇 5. BIG SAVE BUTTON AT THE BOTTOM
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _saveChanges,
                  child: const Text('Save Changes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(String type, String label, ThemeData theme) {
    final isSelected =
        _selectedType == type || (_selectedType == 'qna' && type == 'study');
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.scaffoldBackgroundColor
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showAddConnectionDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<MapController>(context, listen: false);
    final allNodes =
        controller.nodes.where((n) => n.id != widget.node.id).toList();

    String? selectedTargetId;
    final labelCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: const Text('Add Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Connect To Node'),
              dropdownColor: theme.cardColor,
              items: allNodes
                  .map((n) => DropdownMenuItem(
                      value: n.id,
                      child: Text(n.title, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => selectedTargetId = val,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                  labelText: 'Relationship Label (e.g. Why, How, Result)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (selectedTargetId != null) {
                setState(() {
                  _extraConnections.add({
                    'targetId': selectedTargetId,
                    'label': labelCtrl.text.trim().isEmpty
                        ? 'Link'
                        : labelCtrl.text.trim()
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5),
    );
  }
}
