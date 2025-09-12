import 'package:flutter/material.dart';
import '../models/editor_block.dart';

class SlashCommandMenu extends StatelessWidget {
  final String query;
  final Function(BlockType) onCommandSelected;

  const SlashCommandMenu({
    super.key,
    required this.query,
    required this.onCommandSelected,
  });

  List<Map<String, dynamic>> _getFilteredSlashCommands() {
    final commands = [
      {
        'type': BlockType.paragraph,
        'label': 'Paragraph',
        'icon': Icons.text_fields,
        'keywords': ['text', 'paragraph', 'p'],
      },
      {
        'type': BlockType.heading1,
        'label': 'Heading 1',
        'icon': Icons.title,
        'keywords': ['heading', 'h1', 'title'],
      },
      {
        'type': BlockType.heading2,
        'label': 'Heading 2',
        'icon': Icons.title,
        'keywords': ['heading', 'h2', 'subtitle'],
      },
      {
        'type': BlockType.heading3,
        'label': 'Heading 3',
        'icon': Icons.title,
        'keywords': ['heading', 'h3'],
      },
      {
        'type': BlockType.image,
        'label': 'Image',
        'icon': Icons.image,
        'keywords': ['image', 'photo', 'picture', 'img'],
      },
      {
        'type': BlockType.video,
        'label': 'Video',
        'icon': Icons.video_library,
        'keywords': ['video', 'youtube', 'vimeo'],
      },
      {
        'type': BlockType.quote,
        'label': 'Quote',
        'icon': Icons.format_quote,
        'keywords': ['quote', 'blockquote'],
      },
      {
        'type': BlockType.code,
        'label': 'Code Block',
        'icon': Icons.code,
        'keywords': ['code', 'pre'],
      },
      {
        'type': BlockType.divider,
        'label': 'Divider',
        'icon': Icons.horizontal_rule,
        'keywords': ['divider', 'hr', 'line'],
      },
    ];

    if (query.isEmpty) return commands;

    return commands.where((cmd) {
      final label = cmd['label'].toString().toLowerCase();
      final keywords = cmd['keywords'] as List<String>;
      return label.contains(query) ||
          keywords.any((keyword) => keyword.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 250,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: _getFilteredSlashCommands().map((cmd) {
            return ListTile(
              dense: true,
              leading: Icon(cmd['icon'], size: 20),
              title: Text(cmd['label']),
              onTap: () => onCommandSelected(cmd['type']),
              hoverColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ),
    );
  }
}
