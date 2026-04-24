import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:patirchi/core/storage/secure_storage_service.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/empty_placeholder.dart';

/// Xavfsiz saqlash inspector tab.
///
/// Barcha kalit-qiymatlarni ko'rsatadi, o'chirish imkoniyati bilan.
class StorageTab extends StatefulWidget {
  const StorageTab({super.key});

  @override
  State<StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends State<StorageTab> {
  Map<String, String?>? _items;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await SecureStorageService.instance.getAllForDebug();
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteKey(String key) async {
    final confirmed = await _confirmDialog(
      context,
      title: 'Kalitni o\'chirish',
      message: '"$key" kalitini o\'chirasizmi?',
      confirmLabel: 'O\'chirish',
      isDanger: true,
    );
    if (confirmed != true) return;

    await SecureStorageService.instance.delete(key);
    await _loadStorage();
  }

  Future<void> _clearAll() async {
    final first = await _confirmDialog(
      context,
      title: 'Hammasini tozalash',
      message: 'Barcha saqlangan ma\'lumotlar o\'chiriladi. Davom etasizmi?',
      confirmLabel: 'Ha, davom eting',
      isDanger: true,
    );
    if (first != true || !mounted) return;

    final second = await _confirmDialog(
      context,
      title: 'Ishonchingiz komilmi?',
      message: 'Bu amalni bekor qilib bo\'lmaydi!',
      confirmLabel: 'O\'chirish',
      isDanger: true,
    );
    if (second != true) return;

    await SecureStorageService.instance.clearAll();
    await _loadStorage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcha ma\'lumotlar tozalandi'),
          backgroundColor: DevTheme.bgCard,
        ),
      );
    }
  }

  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DevTheme.bgCard,
        title: Text(title, style: const TextStyle(color: DevTheme.textPrimary)),
        content:
            Text(message, style: const TextStyle(color: DevTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Bekor',
              style: TextStyle(color: DevTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDanger ? DevTheme.error : DevTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildBody()),
        _buildClearAllBar(),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(DevTheme.accent),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: DevTheme.error, size: 32),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: DevTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadStorage,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }

    final items = _items;
    if (items == null || items.isEmpty) {
      return const EmptyPlaceholder(
        icon: Icons.lock_outline,
        message: 'Saqlangan ma\'lumotlar yo\'q',
        hint: 'SecureStorageService ga yozilgan kalit-qiymatlar shu yerda.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStorage,
      color: DevTheme.accent,
      backgroundColor: DevTheme.bgCard,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final entry = items.entries.elementAt(i);
          return _StorageRow(
            storageKey: entry.key,
            value: entry.value,
            onCopy: () {
              Clipboard.setData(
                ClipboardData(text: entry.value ?? ''),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nusxalandi'),
                  duration: Duration(seconds: 1),
                  backgroundColor: DevTheme.bgCard,
                ),
              );
            },
            onDelete: () => _deleteKey(entry.key),
          );
        },
      ),
    );
  }

  Widget _buildClearAllBar() {
    return Container(
      color: DevTheme.bgSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text(
            '${_items?.length ?? 0} ta yozuv',
            style: const TextStyle(color: DevTheme.textTertiary, fontSize: 12),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1010),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: DevTheme.error.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_sweep, size: 14, color: DevTheme.error),
                  SizedBox(width: 6),
                  Text(
                    'Hammasini tozalash',
                    style: TextStyle(
                      color: DevTheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Storage row
// ---------------------------------------------------------------------------

class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.storageKey,
    required this.value,
    required this.onCopy,
    required this.onDelete,
  });

  final String storageKey;
  final String? value;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DevTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DevTheme.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storageKey,
                  style: DevTheme.mono.copyWith(
                    fontSize: 12,
                    color: DevTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? '(null)',
                  style: DevTheme.mono.copyWith(
                    fontSize: 11,
                    color: value != null
                        ? DevTheme.textSecondary
                        : DevTheme.textTertiary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 16),
                color: DevTheme.textTertiary,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                color: DevTheme.error.withValues(alpha: 0.7),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
