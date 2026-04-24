import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';
import 'package:patirchi/core/dev_mode/stores/network_log_store.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/empty_placeholder.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/status_chip.dart';
import 'package:patirchi/core/dev_mode/widgets/screens/network_detail_screen.dart';

/// Tarmoq so'rovlari log ko'ruvchi tab.
///
/// Real vaqtda yangilanadi, filter va qidirish imkoniyatiga ega.
class NetworkTab extends StatefulWidget {
  const NetworkTab({super.key});

  @override
  State<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends State<NetworkTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, 2xx, 4xx, 5xx
  String _methodFilter = 'all'; // all, GET, POST, PUT, DELETE

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NetworkLogEntry> _applyFilters(List<NetworkLogEntry> entries) {
    var result = entries;

    // Qidiruv
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.path.toLowerCase().contains(q) ||
                e.url.toLowerCase().contains(q),
          )
          .toList();
    }

    // Status filter
    if (_statusFilter != 'all') {
      result = result
          .where((e) => e.statusCategory == _statusFilter)
          .toList();
    }

    // Method filter
    if (_methodFilter != 'all') {
      result = result
          .where(
            (e) => e.method.toUpperCase() == _methodFilter.toUpperCase(),
          )
          .toList();
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
          'Barcha tarmoq loglari o\'chiriladi. Davom etasizmi?',
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
              context.read<NetworkLogStore>().clear();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkLogStore>(
      builder: (context, store, _) {
        final filtered = _applyFilters(store.entries);

        return Column(
          children: [
            _NetworkTopBar(
              searchController: _searchController,
              statusFilter: _statusFilter,
              methodFilter: _methodFilter,
              totalCount: store.count,
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onStatusFilter: (v) => setState(() => _statusFilter = v),
              onMethodFilter: (v) => setState(() => _methodFilter = v),
              onClear: () => _clearLogs(context),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyPlaceholder(
                      icon: Icons.wifi_off_rounded,
                      message: 'Hech qanday so\'rov yo\'q',
                      hint: 'API chaqiriqlari shu yerda ko\'rinadi.',
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => _NetworkListRow(
                        entry: filtered[i],
                        onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                NetworkDetailScreen(entry: filtered[i]),
                          ),
                        ),
                      ),
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

class _NetworkTopBar extends StatelessWidget {
  const _NetworkTopBar({
    required this.searchController,
    required this.statusFilter,
    required this.methodFilter,
    required this.totalCount,
    required this.onSearchChanged,
    required this.onStatusFilter,
    required this.onMethodFilter,
    required this.onClear,
  });

  final TextEditingController searchController;
  final String statusFilter;
  final String methodFilter;
  final int totalCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilter;
  final ValueChanged<String> onMethodFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DevTheme.bgSecondary,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Qidiruv + tozalash
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
                      hintText: 'URL yoki path qidirish...',
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
              Text(
                '$totalCount',
                style: const TextStyle(
                  color: DevTheme.textTertiary,
                  fontSize: 12,
                  fontFamily: 'monospace',
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
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Hammasi',
                  selected: statusFilter == 'all',
                  onTap: () => onStatusFilter('all'),
                ),
                _FilterChip(
                  label: '2xx',
                  selected: statusFilter == '2xx',
                  onTap: () => onStatusFilter('2xx'),
                  color: DevTheme.success,
                ),
                _FilterChip(
                  label: '4xx',
                  selected: statusFilter == '4xx',
                  onTap: () => onStatusFilter('4xx'),
                  color: DevTheme.warning,
                ),
                _FilterChip(
                  label: '5xx',
                  selected: statusFilter == '5xx',
                  onTap: () => onStatusFilter('5xx'),
                  color: DevTheme.error,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 16,
                  color: DevTheme.borderSubtle,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Hammasi',
                  selected: methodFilter == 'all',
                  onTap: () => onMethodFilter('all'),
                ),
                for (final method in ['GET', 'POST', 'PUT', 'DELETE'])
                  _FilterChip(
                    label: method,
                    selected: methodFilter == method,
                    onTap: () => onMethodFilter(method),
                    color: DevTheme.methodColor(method),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? DevTheme.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.15)
              : DevTheme.bgTertiary,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? activeColor : DevTheme.borderSubtle,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : DevTheme.textTertiary,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List row
// ---------------------------------------------------------------------------

class _NetworkListRow extends StatelessWidget {
  const _NetworkListRow({required this.entry, required this.onTap});

  final NetworkLogEntry entry;
  final VoidCallback onTap;

  String _formatDuration(Duration? d) {
    if (d == null) return '...';
    if (d.inSeconds >= 1) return '${d.inMilliseconds}ms';
    return '${d.inMilliseconds}ms';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: DevTheme.borderSubtle, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            StatusChip.method(entry.method),
            const SizedBox(width: 8),
            StatusChip.status(entry.statusCode),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.path,
                style: DevTheme.mono.copyWith(
                  fontSize: 12,
                  color: DevTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDuration(entry.duration),
                  style: DevTheme.mono.copyWith(
                    fontSize: 11,
                    color: DevTheme.textTertiary,
                  ),
                ),
                Text(
                  _formatTime(entry.timestamp),
                  style: DevTheme.mono.copyWith(
                    fontSize: 10,
                    color: DevTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
