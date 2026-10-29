import 'dart:async';
import 'dart:math';
import 'package:abcitta/screens/workspace_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/map_controller.dart';
import '../controllers/tts_controller.dart';
import '../models/node_model.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui'; // 👈 Blur ke liye zaroori hai

class FocusModeScreen extends StatefulWidget {
  final MindMapNode node;
  const FocusModeScreen({super.key, required this.node});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;
  late MapController _controller;
  bool _hasAutoReviewed = false;
  bool _hasShownMindfulPause = false;
  bool _isNotesHidden = false;
  bool _showConfetti = false;
  late TtsController _tts;
  String _plainText = '';

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<MapController>(context, listen: false);
    _tts = Provider.of<TtsController>(context, listen: false);
    _tts.addListener(_onTtsChanged);
    _checkIfDue();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });

        // 3 Minutes auto-next logic
        if (_secondsElapsed >= 180 && !_hasAutoReviewed) {
          _hasAutoReviewed = true;
          if (widget.node.type == 'study' && widget.node.strength < 100) {
            _controller.reviewNode(widget.node.id);
            _checkIfDue();
          }
          _handleNextNavigation(isAuto: true);
        }

        // Mindful Pause (25 Minutes = 1500 seconds)
        if (_secondsElapsed == 1500 && !_hasShownMindfulPause) {
          _hasShownMindfulPause = true;
          _showMindfulPause();
        }
      }
    });

    if (_tts.autoPlay && widget.node.notes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_tts.isSpeaking) {
            _toggleAudio();
          }
        });
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showAppBar) {
          setState(() => _showAppBar = false);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showAppBar) {
          setState(() => _showAppBar = true);
        }
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToSibling(MindMapNode sibling, {bool isNext = true}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FocusModeScreen(node: sibling),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _handleNextNavigation({bool isAuto = false}) {
    final children = _controller.getChildren(widget.node.id);
    if (children.isNotEmpty) {
      _navigateToSibling(children.first, isNext: true);
      return;
    }

    final siblings = _controller.getChildren(widget.node.parentId);
    final currentIndex = siblings.indexWhere((n) => n.id == widget.node.id);

    if (currentIndex != -1 && currentIndex < siblings.length - 1) {
      _navigateToSibling(siblings[currentIndex + 1], isNext: true);
      return;
    }

    if (widget.node.parentId != null) {
      final parent = _controller.nodes.firstWhere(
          (n) => n.id == widget.node.parentId,
          orElse: () => widget.node);
      if (parent.id != widget.node.id) {
        final parentSiblings = _controller.getChildren(parent.parentId);
        final parentIndex = parentSiblings.indexWhere((n) => n.id == parent.id);
        if (parentIndex != -1 && parentIndex < parentSiblings.length - 1) {
          _navigateToSibling(parentSiblings[parentIndex + 1], isNext: true);
          return;
        }
      }
    }

    if (!isAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('🎉 All nodes in this path completed!'),
            backgroundColor: Colors.green),
      );
    }
  }

  void _showMediaDialog(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _MediaPlayerDialog(item: item),
    );
  }

  void _onTtsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleAudio() async {
    if (_tts.isSpeaking) {
      await _tts.stop();
    } else {
      _plainText = widget.node.notes
          .replaceAll(RegExp(r'[#*`>]'), '')
          .replaceAll(RegExp(r'\n+'), '\n')
          .trim();
      if (_plainText.isEmpty) return;
      await _tts.speak(_plainText);
    }
  }

  void _showVoiceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final tts = Provider.of<TtsController>(context, listen: false);
            return Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Voice Customization',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-play on open',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Start reading automatically',
                          style: TextStyle(fontSize: 11)),
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      value: tts.autoPlay,
                      onChanged: (val) {
                        tts.setAutoPlay(val);
                        setModalState(() {});
                      },
                    ),
                    Divider(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1)),
                    const SizedBox(height: 10),
                    if (tts.availableVoices.isNotEmpty) ...[
                      Text('VOICE CHANGER',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: tts.voiceName,
                            hint: Text('Default Voice',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5))),
                            dropdownColor: Theme.of(context).cardColor,
                            items: tts.availableVoices.map((voice) {
                              return DropdownMenuItem<String>(
                                value: voice['name'],
                                child: Text(
                                    '${voice['name']} (${voice['locale']})',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              if (val != null) {
                                final voice = tts.availableVoices
                                    .firstWhere((v) => v['name'] == val);
                                await tts.setVoice(
                                    voice['name']!, voice['locale']!);
                                setModalState(() {});
                                await tts.speak("Voice updated successfully");
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.1)),
                      const SizedBox(height: 10),
                    ],
                    _buildSlider(
                      title: 'Speed (Rate)',
                      icon: Icons.speed,
                      value: tts.speechRate,
                      min: 0.5,
                      max: 2.5,
                      onChanged: (val) async {
                        await tts.setSpeechRate(val);
                        setModalState(() {});
                        if (_tts.isSpeaking && _plainText.isNotEmpty) {
                          await _tts.stop();
                          await _tts.speak(_plainText);
                        }
                      },
                    ),
                    _buildSlider(
                      title: 'Pitch (Frequency)',
                      icon: Icons.graphic_eq,
                      value: tts.pitch,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (val) async {
                        await tts.setPitch(val);
                        setModalState(() {});
                        if (_tts.isSpeaking && _plainText.isNotEmpty) {
                          await _tts.stop();
                          await _tts.speak(_plainText);
                        }
                      },
                    ),
                    _buildSlider(
                      title: 'Volume',
                      icon: Icons.volume_up,
                      value: tts.volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) async {
                        await tts.setVolume(val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Apply & Close',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlider({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer(),
              Text(value.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor:
                  Theme.of(context).dividerColor.withValues(alpha: 0.2),
            ),
            child:
                Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  void _checkIfDue() {
    if (widget.node.type != 'study') return;
    if (widget.node.dueDate == null || widget.node.dueDate!.isEmpty) return;
    final dueDate = DateTime.tryParse(widget.node.dueDate!);
    if (dueDate == null) return;
  }

  Widget _buildMediaThumbnail(MediaItem item, ThemeData theme) {
    if (item.type == 'image') {
      if (item.isLocal) {
        if (kIsWeb) {
          return Image.network(
            item.url,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Icon(Icons.broken_image,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          );
        }
        return Image.file(
          File(item.url),
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Icon(Icons.broken_image,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        );
      }
      return Image.network(
        item.url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (c, e, s) => Icon(Icons.broken_image,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
      );
    } else if (item.type == 'video') {
      return Center(
        child: Icon(Icons.play_circle_outline,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      );
    } else {
      return Center(
        child: Icon(Icons.headphones,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _tts.removeListener(_onTtsChanged);
    _tts.stop();
    if (_secondsElapsed > 0) {
      _controller.addTimeSpent(widget.node.id, _secondsElapsed);
    }
    super.dispose();
  }

  void _showMindfulPause() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mindful Pause',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You have been focusing for 25 minutes. Take a deep breath.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                TweenAnimationBuilder(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(seconds: 4),
                  curve: Curves.easeInOut,
                  builder: (context, double scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                        ),
                        child: Center(
                          child: Icon(Icons.self_improvement,
                              color: Theme.of(context).colorScheme.primary,
                              size: 40),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Resume Reading',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextContent(ThemeData theme) {
    if (!_tts.isSpeaking) {
      return MarkdownBody(
        data: widget.node.notes,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              fontSize: 16,
              height: 1.8),
          h1: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600),
          h2: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
      );
    }

    int start = _tts.startOffset.clamp(0, _plainText.length);
    int end = _tts.endOffset.clamp(0, _plainText.length);

    if (start == 0 && end == 0) {
      return Text(
        _plainText,
        style: TextStyle(
            color: theme.colorScheme.onSurface, fontSize: 18, height: 1.8),
      );
    }

    if (_tts.speechRate > 1.0) {
      int pStart = _plainText.lastIndexOf('\n', start);
      if (pStart == -1) pStart = 0;
      int pEnd = _plainText.indexOf('\n', end);
      if (pEnd == -1) pEnd = _plainText.length;
      start = pStart;
      end = pEnd;
    }

    String before = _plainText.substring(0, start);
    String current = _plainText.substring(start, end);
    String after = _plainText.substring(end);

    return RichText(
      text: TextSpan(
        style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 18,
            height: 1.8),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: current,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              backgroundColor: const Color(0xFFE8D5B7).withValues(alpha: 0.3),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = _controller.getChildren(widget.node.id);
    final siblings = _controller.getChildren(widget.node.parentId);
    final currentIndex = siblings.indexWhere((n) => n.id == widget.node.id);
    final hasPrevious = currentIndex > 0;
    final hasNext = currentIndex != -1 && currentIndex < siblings.length - 1;
    final isStudyNode = widget.node.type == 'study';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_showAppBar ? kToolbarHeight : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showAppBar ? kToolbarHeight : 0,
          child: AppBar(
            backgroundColor:
                theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [],
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200 && hasNext) {
              _navigateToSibling(siblings[currentIndex + 1], isNext: true);
            } else if (details.primaryVelocity! > 200 && hasPrevious) {
              _navigateToSibling(siblings[currentIndex - 1], isNext: false);
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(widget.node.title,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                      const SizedBox(height: 30),
                      if (widget.node.type == 'qna' &&
                          widget.node.interactiveData != null)
                        _QuizWidget(
                          node: widget.node,
                          onComplete: () {
                            _controller.toggleNodeCompletion(widget.node.id);
                            setState(() {});
                            Future.delayed(const Duration(milliseconds: 1500),
                                () {
                              if (mounted) _handleNextNavigation();
                            });
                          },
                        )
                      else if (widget.node.type == 'game' &&
                          widget.node.interactiveData != null)
                        _GameWidget(
                          node: widget.node,
                          onComplete: () {
                            _controller.toggleNodeCompletion(widget.node.id);
                            setState(() {});
                            Future.delayed(const Duration(milliseconds: 1500),
                                () {
                              if (mounted) _handleNextNavigation();
                            });
                          },
                        )
                      else if (widget.node.notes.isEmpty)
                        Text('No explanation added yet.',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                                fontSize: 16,
                                height: 1.8,
                                fontStyle: FontStyle.italic))
                      else if (_isNotesHidden)
                        GestureDetector(
                          onTap: () => setState(() => _isNotesHidden = false),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: theme.dividerColor
                                      .withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.psychology,
                                    size: 40,
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.5)),
                                const SizedBox(height: 16),
                                Text('Recall the answer in your mind...',
                                    style: TextStyle(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                        fontStyle: FontStyle.italic)),
                                const SizedBox(height: 8),
                                Text('Tap to reveal notes',
                                    style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      else
                        _buildTextContent(theme),
                      if (widget.node.media.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        Text('MEDIA',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: widget.node.media.map((mediaItem) {
                            return GestureDetector(
                              onTap: () => _showMediaDialog(context, mediaItem),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: theme.dividerColor
                                          .withValues(alpha: 0.2)),
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _buildMediaThumbnail(mediaItem, theme),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 40),
                      if (widget.node.links.isNotEmpty) ...[
                        Text('REFERENCES',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 12),
                        ...widget.node.links.map((link) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () async {
                                final uri = Uri.parse(link['url']!);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.2))),
                                child: Row(
                                  children: [
                                    Icon(Icons.link,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                        size: 16),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(link['title']!,
                                              style: TextStyle(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 14)),
                                          if (link['date'] != null)
                                            Text('Added: ${link['date']}',
                                                style: TextStyle(
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withValues(alpha: 0.3),
                                                    fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 40),
                      ],
                      if (children.isNotEmpty) ...[
                        Text('SUB-NODES',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 12),
                        ...children.map((child) {
                          final childColor = Color(int.parse(
                              child.colorHex.replaceFirst('#', '0xFF')));
                          return InkWell(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FocusModeScreen(node: child))),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                  color: theme.cardColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color:
                                              childColor.withValues(alpha: 0.7),
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(child.title,
                                          style: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.8),
                                              fontSize: 14))),
                                  Icon(Icons.arrow_forward_ios,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.2),
                                      size: 12),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 40),
                      // 👈 Minimal strength indicator
                      if (isStudyNode && widget.node.strength < 100)
                        Center(
                          child: Text(
                            '${widget.node.strength}% Strength',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                                fontSize: 11,
                                letterSpacing: 1.5),
                          ),
                        ),

                      const SizedBox(
                          height: 32), // 👈 2 Line Space (16 se 32 kiya)

                      // 👈 NAYA: Timer yahan shift ho gaya
                      Center(
                        child: Text(
                          '⏱️ ${_formatTime(_secondsElapsed)}   |   Spent: ${(widget.node.timeSpentSeconds / 60).toStringAsFixed(1)}m   |   ${widget.node.dueDate != null ? "Due: Scheduled" : "Due: Now"}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ),

            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: _ConfettiWidget(themeColor: theme.colorScheme.primary),
                ),
              ),

            // 👇 NAYA: Transparent Glassmorphism Bottom Bar
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 15, sigmaY: 15), // 👈 Background blur
                  child: Container(
                    height: 64,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor
                          .withValues(alpha: 0.5), // 👈 Highly Transparent
                      borderRadius: BorderRadius.circular(32),
                      border:
                          Border.all(color: Colors.transparent), // 👈 No Border
                      // Shadow hata diya taaki ekdum flat aur clean lage
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. Map Icon (Left)
                        IconButton(
                          icon: Icon(Icons.map_outlined,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 26),
                          onPressed: () {
                            // 👈 Focus Mode se wapas Workspace (Map) mein jao
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WorkspaceScreen()),
                            );
                          },
                        ), // 2. Sound Icon (Center)
                        IconButton(
                          icon: Icon(
                            _tts.isSpeaking ? Icons.pause : Icons.volume_up,
                            color: _tts.isSpeaking
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                            size: 26,
                          ),
                          onPressed: _toggleAudio,
                          onLongPress: () => _showVoiceSettings(context),
                        ),

                        // 3. Done / Review Button (Right)
                        GestureDetector(
                          onTap: () {
                            if (isStudyNode) {
                              if (widget.node.strength >= 100) return;
                              final oldStrength = widget.node.strength;
                              _controller.reviewNode(widget.node.id);
                              _checkIfDue();
                              if (oldStrength < 100 &&
                                  widget.node.strength == 100) {
                                setState(() => _showConfetti = true);
                                Future.delayed(const Duration(seconds: 5), () {
                                  if (mounted) {
                                    setState(() => _showConfetti = false);
                                    _handleNextNavigation();
                                  }
                                });
                              } else {
                                setState(() {});
                                _handleNextNavigation();
                              }
                            } else {
                              if (widget.node.type == 'task') {
                                _controller
                                    .toggleNodeCompletion(widget.node.id);
                              }
                              _handleNextNavigation();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: theme.scaffoldBackgroundColor,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'DONE',
                                  style: TextStyle(
                                    color: theme.scaffoldBackgroundColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (hasPrevious)
              Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor
                                  .withValues(alpha: 0.8),
                              shape: BoxShape.circle),
                          child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.grey, size: 20),
                              onPressed: () => _navigateToSibling(
                                  siblings[currentIndex - 1],
                                  isNext: false))))),
            if (hasNext)
              Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor
                                  .withValues(alpha: 0.8),
                              shape: BoxShape.circle),
                          child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey, size: 20),
                              onPressed: () => _navigateToSibling(
                                  siblings[currentIndex + 1],
                                  isNext: true))))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🎬 MEDIA PLAYER DIALOG
// ==========================================
class _MediaPlayerDialog extends StatefulWidget {
  final MediaItem item;
  const _MediaPlayerDialog({required this.item});

  @override
  State<_MediaPlayerDialog> createState() => _MediaPlayerDialogState();
}

class _MediaPlayerDialogState extends State<_MediaPlayerDialog> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;

  bool _isLoading = true;
  String? _error;

  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isPlaying = false;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  Future<void> _initMedia() async {
    try {
      if (widget.item.type == 'video') {
        await _initVideo();
      } else if (widget.item.type == 'audio') {
        await _initAudio();
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load media: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initVideo() async {
    if (widget.item.isLocal && !kIsWeb) {
      _videoController = VideoPlayerController.file(File(widget.item.url));
    } else {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.item.url));
    }

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFE8D5B7),
        handleColor: const Color(0xFFE8D5B7),
        bufferedColor: Colors.grey,
        backgroundColor: Colors.white24,
      ),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();

    if (widget.item.isLocal && !kIsWeb) {
      await _audioPlayer!.setFilePath(widget.item.url);
    } else {
      await _audioPlayer!.setUrl(widget.item.url);
    }

    _audioDuration = _audioPlayer!.duration ?? Duration.zero;

    _positionSub = _audioPlayer!.positionStream.listen((pos) {
      if (mounted) setState(() => _audioPosition = pos);
    });

    _stateSub = _audioPlayer!.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });

    await _audioPlayer!.play();

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(_iconForType(widget.item.type),
                    color: const Color(0xFFE8D5B7), size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.item.type.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFE8D5B7),
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: _isLoading
                ? const SizedBox(
                    height: 200,
                    width: 300,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFE8D5B7))),
                  )
                : _error != null
                    ? _buildError()
                    : _buildContent(),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'audio':
        return Icons.headphones_outlined;
      default:
        return Icons.image_outlined;
    }
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.item.type) {
      case 'image':
        return _buildImage();
      case 'video':
        return _buildVideo();
      case 'audio':
        return _buildAudio();
      default:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Unknown media type',
              style: TextStyle(color: Colors.white70)),
        );
    }
  }

  Widget _buildImage() {
    if (widget.item.isLocal) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: Image.network(
            widget.item.url,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Failed to load local image on web',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        );
      }
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Image.file(File(widget.item.url), fit: BoxFit.contain),
      );
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Image.network(
        widget.item.url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 200,
            width: 300,
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE8D5B7))),
          );
        },
        errorBuilder: (c, e, s) => const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Failed to load image',
              style: TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_chewieController == null || _videoController == null) {
      return const SizedBox(
        height: 200,
        child: Center(
            child: Text('Video not ready',
                style: TextStyle(color: Colors.white70))),
      );
    }
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildAudio() {
    final maxSec = _audioDuration.inSeconds.toDouble().clamp(1.0, 100000.0);
    final curSec = _audioPosition.inSeconds.toDouble().clamp(0.0, maxSec);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.audiotrack, color: Color(0xFFE8D5B7), size: 64),
          const SizedBox(height: 24),
          Slider(
            value: curSec,
            max: maxSec,
            activeColor: const Color(0xFFE8D5B7),
            inactiveColor: Colors.white24,
            onChanged: (v) => _audioPlayer?.seek(Duration(seconds: v.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_audioPosition),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(_formatDuration(_audioDuration),
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.replay_10, color: Colors.white70),
                onPressed: () {
                  final newPos = _audioPosition - const Duration(seconds: 10);
                  _audioPlayer
                      ?.seek(newPos.isNegative ? Duration.zero : newPos);
                },
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _audioPlayer?.pause();
                  } else {
                    await _audioPlayer?.play();
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE8D5B7), shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.forward_10, color: Colors.white70),
                onPressed: () {
                  final newPos = _audioPosition + const Duration(seconds: 10);
                  _audioPlayer
                      ?.seek(newPos > _audioDuration ? _audioDuration : newPos);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ==========================================
// 🧠 QUIZ WIDGET
// ==========================================
class _QuizWidget extends StatefulWidget {
  final MindMapNode node;
  final VoidCallback onComplete;
  const _QuizWidget({required this.node, required this.onComplete});

  @override
  State<_QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<_QuizWidget> {
  int? _selectedIndex;
  bool _isAnswered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.node.interactiveData!;
    final question = data['question'] ?? 'Question';
    final options = List<String>.from(data['options'] ?? []);
    final correctIndex = data['correctAnswerIndex'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QUIZ',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          Text(question,
              style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ...options.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value;
            if (text.isEmpty) return const SizedBox.shrink();

            bool isSelected = _selectedIndex == idx;
            bool isCorrect = idx == correctIndex;
            Color btnColor = theme.scaffoldBackgroundColor;
            Color borderColor = theme.dividerColor.withValues(alpha: 0.3);
            Color textColor = theme.colorScheme.onSurface;

            if (_isAnswered) {
              if (isCorrect) {
                btnColor = Colors.green.withValues(alpha: 0.15);
                borderColor = Colors.green;
                textColor = Colors.green;
              } else if (isSelected && !isCorrect) {
                btnColor = Colors.redAccent.withValues(alpha: 0.15);
                borderColor = Colors.redAccent;
                textColor = Colors.redAccent;
              }
            }

            return GestureDetector(
              onTap: _isAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = idx;
                        _isAnswered = true;
                      });
                      if (idx == correctIndex) widget.onComplete();
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: borderColor,
                      width: _isAnswered && (isCorrect || isSelected) ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(text,
                            style: TextStyle(color: textColor, fontSize: 15))),
                    if (_isAnswered && isCorrect)
                      const Icon(Icons.check_circle, color: Colors.green),
                    if (_isAnswered && isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: Colors.redAccent),
                  ],
                ),
              ),
            );
          }),
          if (_isAnswered) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _isAnswered = false;
                  _selectedIndex = null;
                }),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Try Again'),
              ),
            )
          ]
        ],
      ),
    );
  }
}

// ==========================================
// 🎮 MEMORY MATCH GAME WIDGET
// ==========================================
class _GameWidget extends StatefulWidget {
  final MindMapNode node;
  final VoidCallback onComplete;
  const _GameWidget({required this.node, required this.onComplete});

  @override
  State<_GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<_GameWidget> {
  List<Map<String, dynamic>> _cards = [];
  final List<int> _flippedIndices = [];
  final Set<int> _matchedIndices = {};
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final pairs = widget.node.interactiveData!['pairs'] as List? ?? [];
    List<Map<String, dynamic>> deck = [];

    for (int i = 0; i < pairs.length; i++) {
      deck.add({'id': i, 'text': pairs[i]['front'] ?? '', 'isFront': true});
      deck.add({'id': i, 'text': pairs[i]['back'] ?? '', 'isFront': false});
    }

    deck.shuffle();
    _cards = deck;
    _flippedIndices.clear();
    _matchedIndices.clear();
  }

  void _onCardTap(int index) {
    if (_isChecking ||
        _flippedIndices.contains(index) ||
        _matchedIndices.contains(index)) {
      return;
    }

    setState(() => _flippedIndices.add(index));

    if (_flippedIndices.length == 2) {
      _isChecking = true;
      final firstIndex = _flippedIndices[0];
      final secondIndex = _flippedIndices[1];

      if (_cards[firstIndex]['id'] == _cards[secondIndex]['id']) {
        setState(() {
          _matchedIndices.add(firstIndex);
          _matchedIndices.add(secondIndex);
          _flippedIndices.clear();
          _isChecking = false;
        });

        if (_matchedIndices.length == _cards.length) {
          widget.onComplete();
        }
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _flippedIndices.clear();
              _isChecking = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MEMORY MATCH',
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              Text('${_matchedIndices.length / 2} / ${_cards.length / 2} Pairs',
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              final isFlipped = _flippedIndices.contains(index) ||
                  _matchedIndices.contains(index);
              final isMatched = _matchedIndices.contains(index);

              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isFlipped
                        ? (isMatched
                            ? Colors.green.withValues(alpha: 0.2)
                            : theme.scaffoldBackgroundColor)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isMatched
                          ? Colors.green
                          : (isFlipped
                              ? theme.colorScheme.primary
                              : theme.dividerColor.withValues(alpha: 0.2)),
                      width: isMatched || isFlipped ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: isFlipped
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              card['text'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isMatched
                                    ? Colors.green
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Icon(Icons.question_mark,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.5),
                            size: 24),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_matchedIndices.length == _cards.length)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => setState(() => _initGame()),
              icon: const Icon(Icons.refresh),
              label: const Text('Play Again'),
            ),
        ],
      ),
    );
  }
}

// ==========================================
// 🎉 LIGHTWEIGHT CONFETTI WIDGET
// ==========================================
class _ConfettiWidget extends StatefulWidget {
  final Color themeColor;
  const _ConfettiWidget({required this.themeColor});

  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..forward();

    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        speed: 0.5 + _random.nextDouble() * 0.5,
        sway: (_random.nextDouble() - 0.5) * 0.1,
        rotation: _random.nextDouble() * 3.14,
        color: _random.nextBool() ? widget.themeColor : Colors.greenAccent,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
              particles: _particles, progress: _controller.value),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double sway;
  final double rotation;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.sway,
    required this.rotation,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      double alpha = 1.0;
      if (progress > 0.7) {
        alpha = (1.0 - (progress - 0.7) * 3.33).clamp(0.0, 1.0);
      }

      final paint = Paint()..color = p.color.withValues(alpha: alpha);
      final currentY = (p.y + progress * 1.2) * size.height;
      final currentX =
          (p.x + sin(progress * 8 + p.rotation) * p.sway) * size.width;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(p.rotation + progress * 5);
      canvas.drawRect(const Rect.fromLTWH(-4, -4, 8, 8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
