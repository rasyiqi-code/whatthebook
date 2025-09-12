import 'package:flutter/material.dart';

class AddBookmarkDialog extends StatefulWidget {
  final Function(String? note, String? bookmarkName) onSave;
  final String? initialNote;
  final String? initialBookmarkName;

  const AddBookmarkDialog({
    super.key,
    required this.onSave,
    this.initialNote,
    this.initialBookmarkName,
  });

  @override
  State<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  late TextEditingController _noteController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _nameController = TextEditingController(text: widget.initialBookmarkName);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Bookmark (Opsional)',
              hintText: 'Contoh: Plot twist penting',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Catatan (Opsional)',
              hintText: 'Tambahkan catatan tentang bagian ini...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final note = _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim();
            final name = _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim();

            widget.onSave(note, name);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
