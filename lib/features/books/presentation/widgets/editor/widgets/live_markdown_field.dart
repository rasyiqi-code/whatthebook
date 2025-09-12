import 'package:flutter/material.dart';
import 'package:whatthebook/features/books/presentation/widgets/editor/utils/markdown_formatter.dart';

class LiveMarkdownField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool readOnly;
  final TextStyle? style;
  final String? hintText;
  final TextAlign textAlign;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final Function(TextSelection)? onSelectionChanged;

  const LiveMarkdownField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.readOnly = false,
    this.style,
    this.hintText,
    this.textAlign = TextAlign.left,
    this.onChanged,
    this.onTap,
    this.onSelectionChanged,
  });

  @override
  State<LiveMarkdownField> createState() => _LiveMarkdownFieldState();
}

class _LiveMarkdownFieldState extends State<LiveMarkdownField> {
  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ?? Theme.of(context).textTheme.bodyMedium;
    final hasMarkdown =
        widget.controller.text.contains('**') ||
        widget.controller.text.contains('_') ||
        widget.controller.text.contains('__');

    return Stack(
      children: [
        // Background formatted text (always visible)
        if (hasMarkdown && !widget.focusNode.hasFocus)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: RichText(
                  text: MarkdownFormatter.formatText(
                    widget.controller.text,
                    textStyle,
                  ),
                  textAlign: widget.textAlign,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),

        // Editable TextField (always present but transparent when not focused)
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          style: widget.focusNode.hasFocus || !hasMarkdown
              ? textStyle
              : textStyle?.copyWith(color: Colors.transparent),
          textAlign: widget.textAlign,
          maxLines: null,
          minLines: 1,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: textStyle?.copyWith(color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to update formatting
            widget.onChanged?.call(value);
            if (widget.onSelectionChanged != null) {
              widget.onSelectionChanged!(
                TextSelection.fromPosition(
                  TextPosition(offset: widget.controller.selection.baseOffset),
                ),
              );
            }
          },
          onTap: () {
            setState(() {}); // Rebuild to show/hide formatting
            widget.onTap?.call();
          },
        ),
      ],
    );
  }
}
