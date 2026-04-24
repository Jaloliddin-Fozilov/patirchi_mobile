import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';

/// Collapsible JSON ko'rsatuvchi widget.
///
/// Map, List va primitive turlarni rang-barang ko'rsatadi.
/// Keys: cyan, Strings: yashil, Numbers: to'q sariq, Booleans: binafsha, null: kulrang.
class JsonTreeView extends StatelessWidget {
  const JsonTreeView({
    super.key,
    required this.data,
    this.initiallyExpanded = true,
    this.showCopyButton = true,
  });

  final dynamic data;
  final bool initiallyExpanded;
  final bool showCopyButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DevTheme.bgTertiary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DevTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCopyButton)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(
                  Icons.copy,
                  size: 14,
                  color: DevTheme.textTertiary,
                ),
                label: const Text(
                  'Copy',
                  style: TextStyle(color: DevTheme.textTertiary, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: _JsonNode(
              data: data,
              depth: 0,
              initiallyExpanded: initiallyExpanded,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    try {
      final encoded = const JsonEncoder.withIndent('  ').convert(data);
      Clipboard.setData(ClipboardData(text: encoded));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON nusxalandi'),
          duration: Duration(seconds: 1),
          backgroundColor: DevTheme.bgCard,
        ),
      );
    } catch (_) {
      Clipboard.setData(ClipboardData(text: data.toString()));
    }
  }
}

/// Rekursiv JSON node widget.
class _JsonNode extends StatefulWidget {
  const _JsonNode({
    required this.data,
    required this.depth,
    required this.initiallyExpanded,
    this.keyLabel,
  });

  final dynamic data;
  final int depth;
  final bool initiallyExpanded;
  final String? keyLabel;

  @override
  State<_JsonNode> createState() => _JsonNodeState();
}

class _JsonNodeState extends State<_JsonNode> {
  late bool _expanded;

  static const int _maxDepth = 10;
  static const double _indentWidth = 16.0;

  // Rang konstantalar
  static const Color _keyColor = Color(0xFF7FC8F8);       // cyan — kalitlar
  static const Color _nullColor = Color(0xFF9E9E9E);      // kulrang — null
  static const Color _bracketColor = Color(0xFF888888);   // kulrang — qavs
  static const Color _lineColor = Color(0xFF2A2A35);      // chiziq

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.depth >= _maxDepth) {
      return Text(
        '...',
        style: DevTheme.mono.copyWith(color: _nullColor),
      );
    }

    if (widget.data is Map) return _buildMap(widget.data as Map);
    if (widget.data is List) return _buildList(widget.data as List);
    return _buildPrimitive();
  }

  Widget _buildMap(Map map) {
    final previewText = '{${map.length} ta kalit}';
    return _buildExpandable(
      previewText: previewText,
      openBracket: '{',
      closeBracket: '}',
      children: map.entries
          .toList()
          .asMap()
          .entries
          .map(
            (e) => _buildEntry(
              keyStr: e.value.key.toString(),
              value: e.value.value,
              isLast: e.key == map.length - 1,
            ),
          )
          .toList(),
    );
  }

  Widget _buildList(List list) {
    final previewText = '[${list.length} ta element]';
    return _buildExpandable(
      previewText: previewText,
      openBracket: '[',
      closeBracket: ']',
      children: list
          .asMap()
          .entries
          .map(
            (e) => _buildIndexEntry(
              index: e.key,
              value: e.value,
              isLast: e.key == list.length - 1,
            ),
          )
          .toList(),
    );
  }

  Widget _buildExpandable({
    required String previewText,
    required String openBracket,
    required String closeBracket,
    required List<Widget> children,
  }) {
    final keyPrefix = widget.keyLabel != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${widget.keyLabel}"',
                style: DevTheme.mono.copyWith(color: _keyColor),
              ),
              Text(
                ': ',
                style: DevTheme.mono.copyWith(color: DevTheme.textSecondary),
              ),
            ],
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (keyPrefix != null) keyPrefix,
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 14,
                color: _bracketColor,
              ),
              Text(
                _expanded ? openBracket : previewText,
                style: DevTheme.mono.copyWith(
                  color: _expanded ? _bracketColor : DevTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: _indentWidth,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _lineColor, width: 1),
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
          Text(
            closeBracket,
            style: DevTheme.mono.copyWith(color: _bracketColor),
          ),
        ],
      ],
    );
  }

  Widget _buildEntry({
    required String keyStr,
    required dynamic value,
    required bool isLast,
  }) {
    final isExpandable = value is Map || value is List;

    if (isExpandable) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, top: 2),
        child: _JsonNode(
          data: value,
          depth: widget.depth + 1,
          initiallyExpanded: widget.depth < 2,
          keyLabel: keyStr,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$keyStr"',
            style: DevTheme.mono.copyWith(color: _keyColor),
          ),
          Text(
            ': ',
            style: DevTheme.mono.copyWith(color: DevTheme.textSecondary),
          ),
          Flexible(
            child: _PrimitiveValue(value: value),
          ),
          if (!isLast)
            Text(',', style: DevTheme.mono.copyWith(color: _bracketColor)),
        ],
      ),
    );
  }

  Widget _buildIndexEntry({
    required int index,
    required dynamic value,
    required bool isLast,
  }) {
    final isExpandable = value is Map || value is List;

    if (isExpandable) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, top: 2),
        child: _JsonNode(
          data: value,
          depth: widget.depth + 1,
          initiallyExpanded: widget.depth < 1,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: _PrimitiveValue(value: value)),
          if (!isLast)
            Text(',', style: DevTheme.mono.copyWith(color: _bracketColor)),
        ],
      ),
    );
  }

  Widget _buildPrimitive() {
    final keyPrefix = widget.keyLabel != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${widget.keyLabel}"',
                style: DevTheme.mono.copyWith(color: _keyColor),
              ),
              Text(
                ': ',
                style: DevTheme.mono.copyWith(color: DevTheme.textSecondary),
              ),
            ],
          )
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (keyPrefix != null) keyPrefix,
        Flexible(child: _PrimitiveValue(value: widget.data)),
      ],
    );
  }
}

class _PrimitiveValue extends StatelessWidget {
  const _PrimitiveValue({required this.value});

  final dynamic value;

  static const Color _stringColor = Color(0xFF7EC986);
  static const Color _numberColor = Color(0xFFD19A66);
  static const Color _boolColor = Color(0xFFC678DD);
  static const Color _nullColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Text('null', style: DevTheme.mono.copyWith(color: _nullColor));
    }

    if (value is String) {
      return Text(
        '"$value"',
        style: DevTheme.mono.copyWith(color: _stringColor),
      );
    }

    if (value is bool) {
      return Text(
        value.toString(),
        style: DevTheme.mono.copyWith(color: _boolColor),
      );
    }

    if (value is num) {
      return Text(
        value.toString(),
        style: DevTheme.mono.copyWith(color: _numberColor),
      );
    }

    return Text(
      value.toString(),
      style: DevTheme.mono.copyWith(color: DevTheme.textSecondary),
    );
  }
}
