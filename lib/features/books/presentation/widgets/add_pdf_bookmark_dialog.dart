import 'package:flutter/material.dart';

class AddPdfBookmarkDialog extends StatefulWidget {
  final String? initialNote;
  final String? initialBookmarkName;
  final void Function(String note, String bookmarkName) onSave;
  const AddPdfBookmarkDialog({
    super.key,
    this.initialNote,
    this.initialBookmarkName,
    required this.onSave,
  });

  @override
  State<AddPdfBookmarkDialog> createState() => _AddPdfBookmarkDialogState();
}

class _AddPdfBookmarkDialogState extends State<AddPdfBookmarkDialog> {
  late TextEditingController _noteController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _nameController = TextEditingController(
      text: widget.initialBookmarkName ?? '',
    );
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
      title: const Text('Tambah/Edit Bookmark'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama Bookmark'),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Catatan'),
            maxLines: 2,
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
            widget.onSave(_noteController.text, _nameController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
