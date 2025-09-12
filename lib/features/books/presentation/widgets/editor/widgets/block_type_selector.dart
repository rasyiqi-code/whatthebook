import 'package:flutter/material.dart';
import '../models/editor_block.dart';
import 'block_type_chip.dart';

class BlockTypeSelector extends StatelessWidget {
  final Function(BlockType) onTypeSelected;

  const BlockTypeSelector({super.key, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Change Block Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BlockTypeChip(
                icon: Icons.text_fields,
                label: 'Paragraph',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.paragraph);
                },
              ),
              BlockTypeChip(
                icon: Icons.title,
                label: 'Heading 1',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.heading1);
                },
              ),
              BlockTypeChip(
                icon: Icons.title,
                label: 'Heading 2',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.heading2);
                },
              ),
              BlockTypeChip(
                icon: Icons.title,
                label: 'Heading 3',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.heading3);
                },
              ),
              BlockTypeChip(
                icon: Icons.image,
                label: 'Image',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.image);
                },
              ),
              BlockTypeChip(
                icon: Icons.video_library,
                label: 'Video',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.video);
                },
              ),
              BlockTypeChip(
                icon: Icons.format_quote,
                label: 'Quote',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.quote);
                },
              ),
              BlockTypeChip(
                icon: Icons.code,
                label: 'Code',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.code);
                },
              ),
              BlockTypeChip(
                icon: Icons.horizontal_rule,
                label: 'Divider',
                onTap: () {
                  Navigator.pop(context);
                  onTypeSelected(BlockType.divider);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
