import 'package:flutter/material.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/models/editor_block.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/widgets/live_markdown_field.dart';

class BlockWidget extends StatefulWidget {
  final EditorBlock block;
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool readOnly;
  final Function(bool) onFocusChanged;
  final Function(String) onContentChanged;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onTypeChange;
  final VoidCallback onDelete;
  final List<EditorBlock> blocks;
  final Function(int, int) onReorder;
  final Function(TextSelection) onSelectionChanged;

  const BlockWidget({
    super.key,
    required this.block,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.readOnly,
    required this.onFocusChanged,
    required this.onContentChanged,
    required this.onSelectionChanged,
    required this.onEnterPressed,
    required this.onBackspacePressed,
    required this.onTypeChange,
    required this.onDelete,
    required this.blocks,
    required this.onReorder,
  });

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleSelectionChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleSelectionChange);
    super.dispose();
  }

  void _handleSelectionChange() {
    if (widget.controller.selection.isValid) {
      widget.onSelectionChanged(widget.controller.selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<EditorBlock>(
      data: widget.block,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.controller.text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      onDragStarted: () => setState(() => isDragging = true),
      onDragEnd: (_) => setState(() => isDragging = false),
      child: DragTarget<EditorBlock>(
        onWillAcceptWithDetails: (details) => details.data != widget.block,
        onAcceptWithDetails: (details) {
          final fromIndex = widget.index;
          final toIndex = widget.blocks.indexOf(details.data);
          widget.onReorder(fromIndex, toIndex);
        },
        builder: (context, candidateData, rejectedData) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.isFocused
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: _buildBlockContent(context))],
                    ),
                    // Delete button in top right corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.6),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Add block button in bottom right corner
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onEnterPressed,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBlockContent(BuildContext context) {
    switch (widget.block.type) {
      case BlockType.heading1:
        return _buildTextField(
          context,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          hintText: 'Heading 1',
        );
      case BlockType.heading2:
        return _buildTextField(
          context,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          hintText: 'Heading 2',
        );
      case BlockType.heading3:
        return _buildTextField(
          context,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          hintText: 'Heading 3',
        );
      case BlockType.quote:
        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Theme.of(context).primaryColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.only(left: 16),
          child: _buildTextField(
            context,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
            hintText: 'Quote',
          ),
        );
      case BlockType.code:
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(12),
          child: _buildTextField(
            context,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            hintText: 'Code',
          ),
        );
      case BlockType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.controller.text.isEmpty)
              _buildTextField(
                context,
                hintText: 'Paste image URL or upload...',
              ),
            if (widget.controller.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.network(
                  widget.controller.text,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(16),
                    child: const Text('Invalid image URL'),
                  ),
                ),
              ),
          ],
        );
      case BlockType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.controller.text.isEmpty)
              _buildTextField(
                context,
                hintText: 'Paste video URL (YouTube, Vimeo)...',
              ),
            if (widget.controller.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Text(
                        'Video: ${widget.controller.text}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      case BlockType.divider:
        return Container(
          height: 1,
          margin: const EdgeInsets.symmetric(vertical: 16),
          color: Colors.grey[300],
        );
      default: // paragraph
        return _buildTextField(context, hintText: 'Type / for commands');
    }
  }

  Widget _buildTextField(
    BuildContext context, {
    TextStyle? style,
    String? hintText,
  }) {
    if (widget.block.type == BlockType.divider) {
      return const SizedBox.shrink();
    }

    // Get text alignment from block metadata
    final alignment = widget.block.metadata['alignment'] as String?;
    TextAlign textAlign = TextAlign.left;
    switch (alignment) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    return LiveMarkdownField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      style: style,
      hintText: hintText,
      textAlign: textAlign,
      onChanged: widget.onContentChanged,
      onTap: () => widget.onFocusChanged(true),
      onSelectionChanged: widget.onSelectionChanged,
    );
  }
}
