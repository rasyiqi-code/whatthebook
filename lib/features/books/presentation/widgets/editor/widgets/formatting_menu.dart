import 'package:flutter/material.dart';

class FormattingMenu extends StatelessWidget {
  final Function(String) onFormatSelected;

  const FormattingMenu({super.key, required this.onFormatSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold),
              onPressed: () => onFormatSelected('bold'),
              tooltip: 'Bold',
            ),
            IconButton(
              icon: const Icon(Icons.format_italic),
              onPressed: () => onFormatSelected('italic'),
              tooltip: 'Italic',
            ),
            IconButton(
              icon: const Icon(Icons.format_underlined),
              onPressed: () => onFormatSelected('underline'),
              tooltip: 'Underline',
            ),
            IconButton(
              icon: const Icon(Icons.format_align_left),
              onPressed: () => onFormatSelected('align_left'),
              tooltip: 'Align Left',
            ),
            IconButton(
              icon: const Icon(Icons.format_align_center),
              onPressed: () => onFormatSelected('align_center'),
              tooltip: 'Align Center',
            ),
            IconButton(
              icon: const Icon(Icons.format_align_right),
              onPressed: () => onFormatSelected('align_right'),
              tooltip: 'Align Right',
            ),
          ],
        ),
      ),
    );
  }
}
