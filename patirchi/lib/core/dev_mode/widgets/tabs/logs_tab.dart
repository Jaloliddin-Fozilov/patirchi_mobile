import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:patirchi/core/dev_mode/models/log_entry.dart';
import 'package:patirchi/core/dev_mode/stores/log_store.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/empty_placeholder.dart';

/// App log yozuvlarini ko'rsatuvchi tab.
///
/// Real vaqtda yangilanadi, level filter va qidirish imkoniyatiga ega.
class LogsTab extends StatefulWidget {
  const LogsTab({super.key});

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  LogLevel? _levelFilter; // null = hammasi

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> _applyFilters(List<LogEntry> entries) {
    var result = entries;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.message.toLowerCase().contains(q) ||
                (e.tag?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    if (_levelFilter != null) {
      result = result.where((e) => e.level == _levelFilter).toList();
    }

    return result;
  }

  void _clearLogs(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DevTheme.bgCard,
        title: const Text(
          'Loglarni tozalash',
          style: TextStyle(color: DevTheme.textPrimary),
        ),
        content: const Text(
          'Barcha log yozuvlari o\'chiriladi.',
          style: TextStyle(color: DevTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Bekor',
              style: TextStyle(color: DevTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<LogStore>().clear();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Tozalash',
              style: TextStyle(color: DevTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAll(List<LogEntry> entries) {
    final buffer = StringBuffer();
    for (final e in entries) {
      buffer.writeln('[${e.formattedTimestamp}] [${e.levelShort}]'
          '${e.tag != null ? " [${e.tag}]" : ""} ${e.message}');
      if (e.stackTrace != null) {
        buffer.writeln(e.stackTrace);
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LogStore>(
      builder: (context, store, _) {
        final filtered = _applyFilters(store.entries);

        return Column(
          children: [
            _LogsTopBar(
              searchController: _searchController,
              levelFilter: _levelFilter,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onLevelFilter: (v) => setState(() => _levelFilter = v),
              onClear: () => _clearLogs(context),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyPlaceholder(
                      icon: Icons.receipt_long_outlined,
                      message: 'Hech qanday log yo\'q',
                      hint:
                          'AppLogger.i(...) orqali log yozuvlarini qo\'shing.',
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _LogRow(entry: filtered[i]),
                    ),
            ),
            // Bottom bar: Copy all
            Container(
              color: DevTheme.bgSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _copyAll(filtered);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${filtered.length} ta log nusxalandi',
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: DevTheme.bgCard,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_all,
                          size: 14,
                          color: DevTheme.textTertiary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hammasini nusxalash',
                          style: TextStyle(
                            color: DevTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _LogsTopBar extends StatelessWidget {
  const _LogsTopBar({
    required this.searchController,
    required this.levelFilter,
    required this.onSearchChanged,
    required this.onLevelFilter,
    required this.onClear,
  });

  final TextEditingController searchController;
  final LogLevel? levelFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<LogLevel?> onLevelFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DevTheme.bgSecondary,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: const TextStyle(
                      color: DevTheme.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Xabar yoki tag qidirish...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                        color: DevTheme.textTertiary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: DevTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _LevelChip(
                  label: 'Hammasi',
                  selected: levelFilter == null,
                  color: DevTheme.textSecondary,
                  onTap: () => onLevelFilter(null),
                ),
                _LevelChip(
                  label: 'Debug',
                  selected: levelFilter == LogLevel.debug,
                  color: DevTheme.textTertiary,
                  onTap: () => onLevelFilter(LogLevel.debug),
                ),
                _LevelChip(
                  label: 'Info',
                  selected: levelFilter == LogLevel.info,
                  color: DevTheme.info,
                  onTap: () => onLevelFilter(LogLevel.info),
                ),
                _LevelChip(
                  label: 'Warn',
                  selected: levelFilter == LogLevel.warn,
                  color: DevTheme.warning,
                  onTap: () => onLevelFilter(LogLevel.warn),
                ),
                _LevelChip(
                  label: 'Error',
                  selected: levelFilter == LogLevel.error,
                  color: DevTheme.error,
                  onTap: () => onLevelFilter(LogLevel.error),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : DevTheme.bgTertiary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? color : DevTheme.borderSubtle,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : DevTheme.textTertiary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Log row
// ---------------------------------------------------------------------------

class _LogRow extends StatefulWidget {
  const _LogRow({required this.entry});

  final LogEntry entry;

  @override
  State<_LogRow> createState() => _LogRowState();
}

class _LogRowState extends State<_LogRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final levelColor = DevTheme.logLevelColor(entry.level);

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DevTheme.borderSubtle, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level dot
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: levelColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Timestamp
                Text(
                  entry.formattedTimestamp,
                  style: DevTheme.mono.copyWith(
                    fontSize: 10,
                    color: DevTheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                // Tag
                if (entry.tag != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: DevTheme.bgTertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      entry.tag!,
                      style: DevTheme.mono.copyWith(
                        fontSize: 10,
                        color: DevTheme.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Message
                Expanded(
                  child: Text(
                    entry.message,
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: _expanded ? null : 2,
                    overflow:
                        _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              if (entry.stackTrace != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DevTheme.bgTertiary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.stackTrace!,
                    style: DevTheme.mono.copyWith(
                      fontSize: 10,
                      color: DevTheme.textTertiary,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    final text =
                        '[${entry.formattedTimestamp}] [${entry.levelShort}]'
                        '${entry.tag != null ? " [${entry.tag}]" : ""} ${entry.message}';
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nusxalandi'),
                        duration: Duration(seconds: 1),
                        backgroundColor: DevTheme.bgCard,
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 12, color: DevTheme.textTertiary),
                      SizedBox(width: 4),
                      Text(
                        'Nusxalash',
                        style: TextStyle(
                          color: DevTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
