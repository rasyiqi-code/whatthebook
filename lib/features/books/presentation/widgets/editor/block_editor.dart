import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'package:whatthebook/features/books/presentation/widgets/editor/models/editor_block.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/widgets/block_widget.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/widgets/block_type_selector.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/widgets/slash_command_menu.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/widgets/formatting_menu.dart';

class BlockEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String content, int wordCount)? onContentChanged;
  final Function(String content, int wordCount)? onAutoSave;
  final bool readOnly;

  const BlockEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    this.onAutoSave,
    this.readOnly = false,
  });

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  List<EditorBlock> blocks = [];
  int? focusedBlockIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _showSlashMenu = false;
  int? _slashMenuBlockIndex;
  String _slashQuery = '';

  // Text formatting popup state
  bool _showFormattingMenu = false;
  int? _formattingMenuBlockIndex;
  Offset? _formattingMenuPosition;
  TextSelection? _currentSelection;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
  }

  void _initializeBlocks() {
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final data = jsonDecode(widget.initialContent!);
        if (data is List) {
          blocks = data.map((json) => EditorBlock.fromJson(json)).toList();
        }
      } catch (e) {
        blocks = [
          EditorBlock(
            id: _generateId(),
            type: BlockType.paragraph,
            content: widget.initialContent!,
          ),
        ];
      }
    }

    if (blocks.isEmpty) {
      blocks = [EditorBlock(id: _generateId(), type: BlockType.paragraph)];
    }

    _initializeControllers();
  }

  void _initializeControllers() {
    for (final block in blocks) {
      _controllers[block.id] = TextEditingController(text: block.content);
      _focusNodes[block.id] = FocusNode();
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _reorderBlock(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final block = blocks.removeAt(oldIndex);
      blocks.insert(newIndex, block);
      _notifyContentChanged();
    });
  }

  void _addBlock(BlockType type, {int? afterIndex}) {
    final newBlock = EditorBlock(id: _generateId(), type: type);
    final insertIndex = afterIndex != null ? afterIndex + 1 : blocks.length;

    setState(() {
      blocks.insert(insertIndex, newBlock);
      _controllers[newBlock.id] = TextEditingController();
      _focusNodes[newBlock.id] = FocusNode();
      focusedBlockIndex = insertIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[newBlock.id]?.requestFocus();
    });

    _notifyContentChanged();
  }

  void _deleteBlock(int index) {
    if (blocks.length <= 1) return;

    final block = blocks[index];
    setState(() {
      blocks.removeAt(index);
      _controllers[block.id]?.dispose();
      _focusNodes[block.id]?.dispose();
      _controllers.remove(block.id);
      _focusNodes.remove(block.id);

      if (focusedBlockIndex == index) {
        focusedBlockIndex = index > 0 ? index - 1 : 0;
        if (focusedBlockIndex! < blocks.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNodes[blocks[focusedBlockIndex!].id]?.requestFocus();
          });
        }
      }
    });

    _notifyContentChanged();
  }

  void _changeBlockType(int index, BlockType newType) {
    setState(() {
      blocks[index] = EditorBlock(
        id: blocks[index].id,
        type: newType,
        content: blocks[index].content,
        metadata: blocks[index].metadata,
      );
    });

    _notifyContentChanged();
  }

  void _notifyContentChanged() {
    final content = jsonEncode(blocks.map((b) => b.toJson()).toList());
    final wordCount = _calculateWordCount();

    widget.onContentChanged?.call(content, wordCount);

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      widget.onAutoSave?.call(content, wordCount);
    });
  }

  void _handleSelectionChanged(TextSelection selection, int blockIndex) {
    if (selection.isValid && selection.baseOffset != selection.extentOffset) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final blockPosition = renderBox.localToGlobal(Offset.zero);
      final textHeight = 20.0;

      setState(() {
        _showFormattingMenu = true;
        _formattingMenuBlockIndex = blockIndex;
        _currentSelection = selection;
        _formattingMenuPosition = Offset(
          blockPosition.dx + 16,
          blockPosition.dy + (blockIndex * textHeight) - 40,
        );
      });
    } else {
      setState(() {
        _showFormattingMenu = false;
        _formattingMenuBlockIndex = null;
        _currentSelection = null;
        _formattingMenuPosition = null;
      });
    }
  }

  void _applyTextFormatting(String format) {
    if (_formattingMenuBlockIndex == null || _currentSelection == null) return;

    final block = blocks[_formattingMenuBlockIndex!];
    final controller = _controllers[block.id]!;
    final text = controller.text;
    final selection = _currentSelection!;

    String newText;
    switch (format) {
      case 'bold':
        newText = text.replaceRange(
          selection.baseOffset,
          selection.extentOffset,
          '**${text.substring(selection.baseOffset, selection.extentOffset)}**',
        );
        break;
      case 'italic':
        newText = text.replaceRange(
          selection.baseOffset,
          selection.extentOffset,
          '_${text.substring(selection.baseOffset, selection.extentOffset)}_',
        );
        break;
      case 'underline':
        newText = text.replaceRange(
          selection.baseOffset,
          selection.extentOffset,
          '__${text.substring(selection.baseOffset, selection.extentOffset)}__',
        );
        break;
      case 'align_left':
      case 'align_center':
      case 'align_right':
        // Store alignment in block metadata
        final alignmentType = format.split(
          '_',
        )[1]; // Extract 'left', 'center', or 'right'
        block.metadata['alignment'] = alignmentType;
        newText = text; // No text change for alignment
        break;
      default:
        return;
    }

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + newText.length - text.length,
      ),
    );

    block.content = newText;
    _notifyContentChanged();

    setState(() {
      _showFormattingMenu = false;
      _formattingMenuBlockIndex = null;
      _currentSelection = null;
      _formattingMenuPosition = null;
    });
  }

  void _handleSlashCommand(int blockIndex, String text) {
    if (text.startsWith('/')) {
      setState(() {
        _showSlashMenu = true;
        _slashMenuBlockIndex = blockIndex;
        _slashQuery = text.substring(1).toLowerCase();
      });
    } else {
      setState(() {
        _showSlashMenu = false;
        _slashMenuBlockIndex = null;
        _slashQuery = '';
      });
    }
  }

  void _executeSlashCommand(BlockType type) {
    if (_slashMenuBlockIndex != null) {
      _changeBlockType(_slashMenuBlockIndex!, type);
      _controllers[blocks[_slashMenuBlockIndex!].id]?.clear();
      setState(() {
        _showSlashMenu = false;
        _slashMenuBlockIndex = null;
        _slashQuery = '';
      });
    }
  }

  int _calculateWordCount() {
    return blocks
        .map((b) => b.content.trim())
        .where((content) => content.isNotEmpty)
        .map((content) => content.split(RegExp(r'\s+')).length)
        .fold(0, (sum, count) => sum + count);
  }

  void _showBlockTypeSelector(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlockTypeSelector(
        onTypeSelected: (type) => _changeBlockType(index, type),
      ),
    );
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  final block = blocks[index];
                  return BlockWidget(
                    key: ValueKey(block.id),
                    block: block,
                    blocks: blocks,
                    index: index,
                    controller: _controllers[block.id]!,
                    focusNode: _focusNodes[block.id]!,
                    isFocused: focusedBlockIndex == index,
                    readOnly: widget.readOnly,
                    onFocusChanged: (hasFocus) {
                      setState(() {
                        focusedBlockIndex = hasFocus ? index : null;
                      });
                    },
                    onContentChanged: (content) {
                      block.content = content;
                      _handleSlashCommand(index, content);
                      _notifyContentChanged();
                    },
                    onSelectionChanged: (selection) {
                      _handleSelectionChanged(selection, index);
                    },
                    onEnterPressed: () =>
                        _addBlock(BlockType.paragraph, afterIndex: index),
                    onBackspacePressed: () {
                      if (block.content.isEmpty && blocks.length > 1) {
                        _deleteBlock(index);
                      }
                    },
                    onTypeChange: () => _showBlockTypeSelector(index),
                    onDelete: () => _deleteBlock(index),
                    onReorder: _reorderBlock,
                  );
                },
              ),

              if (_showSlashMenu && _slashMenuBlockIndex != null)
                Positioned(
                  left: 16,
                  top: (_slashMenuBlockIndex! * 48.0) + 16,
                  child: SlashCommandMenu(
                    query: _slashQuery,
                    onCommandSelected: _executeSlashCommand,
                  ),
                ),

              if (_showFormattingMenu && _formattingMenuPosition != null)
                Positioned(
                  left: _formattingMenuPosition!.dx,
                  top: _formattingMenuPosition!.dy,
                  child: FormattingMenu(onFormatSelected: _applyTextFormatting),
                ),
            ],
          ),
        ),

        if (!widget.readOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Blocks: ${blocks.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  'Words: ${_calculateWordCount()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  'Auto-save enabled',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
