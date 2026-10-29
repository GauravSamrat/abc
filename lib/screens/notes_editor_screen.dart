import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart'; // 👈 Delta ke liye sahi path
import 'package:markdown_quill/markdown_quill.dart';
import 'package:markdown/markdown.dart' as md;

class NotesEditorScreen extends StatefulWidget {
  final String initialText;
  final String title;
  const NotesEditorScreen(
      {super.key, required this.initialText, required this.title});

  @override
  State<NotesEditorScreen> createState() => _NotesEditorScreenState();
}

class _NotesEditorScreenState extends State<NotesEditorScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    if (widget.initialText.isEmpty) {
      _controller = quill.QuillController.basic();
    } else {
      try {
        // Markdown ko Quill Delta me convert karo
        final mdToDelta = MarkdownToDelta(markdownDocument: md.Document());
        final delta = mdToDelta.convert(widget.initialText);
        _controller = quill.QuillController(
          document: quill.Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // Agar koi purana corrupt data ho toh simple text dikhao
        _controller = quill.QuillController.basic();
        _controller.document.insert(0, widget.initialText);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    // Quill Delta ko wapas Markdown me convert karo
    final deltaJson = _controller.document.toDelta().toJson();
    final deltaToMd = DeltaToMarkdown();
    final markdownText = deltaToMd.convert(Delta.fromJson(deltaJson));

    Navigator.pop(context, markdownText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _saveAndClose,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE8D5B7),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // 👇 1. WYSIWYG Editor Area
          Expanded(
            child: quill.QuillEditor.basic(
              controller: _controller,
              focusNode: _focusNode,
              scrollController: _scrollController,
              config: quill.QuillEditorConfig(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                placeholder: 'Start writing your masterpiece...',
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        height: 1.6),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(8, 0),
                    null,
                  ),
                  h1: quill.DefaultTextBlockStyle(
                    TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(16, 0),
                    null,
                  ),
                  h2: quill.DefaultTextBlockStyle(
                    TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(12, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),

          // 👇 2. Minimalist Bottom Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                  top: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.2))),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Formatting Tools
                    _buildToolbarButton(Icons.format_bold, 'Bold',
                        () => _formatSelection(quill.Attribute.bold)),
                    _buildToolbarButton(Icons.format_italic, 'Italic',
                        () => _formatSelection(quill.Attribute.italic)),
                    _buildToolbarButton(Icons.format_underline, 'Underline',
                        () => _formatSelection(quill.Attribute.underline)),
                    _buildToolbarButton(Icons.format_strikethrough, 'Strike',
                        () => _formatSelection(quill.Attribute.strikeThrough)),

                    _buildDivider(),

                    // Block Tools
                    _buildToolbarButton(
                        Icons.title, 'Heading 1', () => _applyHeader(1)),
                    _buildToolbarButton(
                        Icons.text_fields, 'Heading 2', () => _applyHeader(2)),
                    _buildToolbarButton(
                        Icons.format_list_bulleted,
                        'Bullet List',
                        () => _formatSelection(quill.Attribute.ul)),
                    _buildToolbarButton(
                        Icons.format_list_numbered,
                        'Numbered List',
                        () => _formatSelection(quill.Attribute.ol)),
                    _buildToolbarButton(Icons.format_quote, 'Quote',
                        () => _formatSelection(quill.Attribute.blockQuote)),

                    _buildDivider(),

                    // Insert Tools
                    _buildToolbarButton(
                        Icons.link, 'Insert Link', _showLinkDialog),
                    _buildToolbarButton(
                        Icons.image, 'Insert Image', _showImageDialog),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Toolbar Button Builder
  Widget _buildToolbarButton(
      IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          size: 22),
      tooltip: tooltip,
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  // Divider Builder
  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
    );
  }

  // Formatting Logic (Toggle)
  void _formatSelection(quill.Attribute attribute) {
    final selection = _controller.selection;
    if (selection.isCollapsed) return;

    final currentAttributes = _controller.getSelectionStyle().attributes;
    final isActive = currentAttributes.containsKey(attribute.key);

    _controller.formatSelection(
      isActive ? quill.Attribute.clone(attribute, null) : attribute,
    );
  }

  // Heading Logic
  void _applyHeader(int level) {
    final selection = _controller.selection;
    if (selection.isCollapsed) return;

    _controller.formatSelection(
      level == 1 ? quill.Attribute.h1 : quill.Attribute.h2,
    );
  }

  // Link Insert Dialog
  void _showLinkDialog() {
    final textCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Insert Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: textCtrl,
                decoration:
                    const InputDecoration(labelText: 'Text to display')),
            TextField(
                controller: urlCtrl,
                decoration:
                    const InputDecoration(labelText: 'URL (https://...)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (textCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                final index = _controller.selection.start;
                _controller.document.insert(index, textCtrl.text);
                _controller.formatText(index, textCtrl.text.length,
                    quill.LinkAttribute(urlCtrl.text));
                _controller.updateSelection(
                    TextSelection.collapsed(
                        offset: index + textCtrl.text.length),
                    quill.ChangeSource.local);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  // Image Insert Dialog
  void _showImageDialog() {
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Insert Image URL'),
        content: TextField(
            controller: urlCtrl,
            decoration: const InputDecoration(labelText: 'Image URL')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (urlCtrl.text.isNotEmpty) {
                final index = _controller.selection.start;
                _controller.document
                    .insert(index, quill.BlockEmbed.image(urlCtrl.text));
                _controller.updateSelection(
                    TextSelection.collapsed(offset: index + 1),
                    quill.ChangeSource.local);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }
}
