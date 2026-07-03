import 'package:flutter/material.dart';

class IndigenousAccessoryBar extends StatelessWidget {
  const IndigenousAccessoryBar({
    super.key,
    required this.onInsert,
  });

  final ValueChanged<String> onInsert;

  static const symbols = [
    "'",
    '^',
    '_',
    '·',
    '-',
    '?',
    '!',
    '(',
    ')',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: symbols
            .map(
              (symbol) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text(
                    symbol,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => onInsert(symbol),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class IndigenousTextField extends StatefulWidget {
  const IndigenousTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.maxLines = 1,
    required this.onChanged,
  });

  final String label;
  final String? hint;
  final String? initialValue;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  State<IndigenousTextField> createState() => _IndigenousTextFieldState();
}

class _IndigenousTextFieldState extends State<IndigenousTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertSymbol(String symbol) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final updated = text.replaceRange(start, end, symbol);
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: start + symbol.length),
    );
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IndigenousAccessoryBar(onInsert: _insertSymbol),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
          ),
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
