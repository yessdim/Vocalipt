import 'package:flutter/material.dart';

class ManageHighlightsDialog extends StatefulWidget {
  final List<String> baseWords;
  final Function(String) onWordAdded;
  final Function(String) onWordDeleted;

  const ManageHighlightsDialog({
    Key? key,
    required this.baseWords,
    required this.onWordAdded,
    required this.onWordDeleted,
  }) : super(key: key);

  @override
  State<ManageHighlightsDialog> createState() => _ManageHighlightsDialogState();
}

class _ManageHighlightsDialogState extends State<ManageHighlightsDialog> {
  final TextEditingController _highlightController = TextEditingController();

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  void _submitData() {
    final text = _highlightController.text.trim();
    if (text.isNotEmpty) {
      widget.onWordAdded(text);
      _highlightController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dynamic Highlights'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add new keywords that the app will highlight instantly:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _highlightController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter keyword (e.g., Hello)',
                isDense: true,
              ),
              onSubmitted: (_) => _submitData(),
            ),
            const SizedBox(height: 16),
            Text(
              'Active Words:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  widget.baseWords
                      .map(
                        (word) => Chip(
                          label: Text(word),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onDeleted: () {
                            widget.onWordDeleted(word);
                            setState(() {});
                          },
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(onPressed: _submitData, child: const Text('Add')),
      ],
    );
  }
}
