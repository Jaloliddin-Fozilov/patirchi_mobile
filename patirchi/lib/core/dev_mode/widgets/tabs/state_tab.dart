import 'package:flutter/material.dart';

import 'package:patirchi/core/dev_mode/provider_registry.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/empty_placeholder.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/json_tree_view.dart';

/// Provider state inspector tab.
///
/// ProviderRegistry ga qo'shilgan barcha providerlarning snapshotlarini ko'rsatadi.
class StateTab extends StatefulWidget {
  const StateTab({super.key});

  @override
  State<StateTab> createState() => _StateTabState();
}

class _StateTabState extends State<StateTab> {
  List<({String name, Map<String, dynamic> data})> _snapshots = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _loading = true);
    try {
      _snapshots = ProviderRegistry.snapshotAll();
    } catch (e) {
      _snapshots = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Container(
          color: DevTheme.bgSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Text(
                'Provider State',
                style: TextStyle(
                  color: DevTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _refresh,
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DevTheme.accent,
                          ),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: 16,
                            color: DevTheme.accent,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Yangilash',
                            style: TextStyle(
                              color: DevTheme.accent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _snapshots.isEmpty
              ? const EmptyPlaceholder(
                  icon: Icons.device_hub_outlined,
                  message: 'Providerlar topilmadi',
                  hint:
                      'ProviderRegistry ga hech qanday provider qo\'shilmagan',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _snapshots.length,
                  itemBuilder: (_, i) => _ProviderCard(
                    snapshot: _snapshots[i],
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Provider card
// ---------------------------------------------------------------------------

class _ProviderCard extends StatefulWidget {
  const _ProviderCard({required this.snapshot});

  final ({String name, Map<String, dynamic> data}) snapshot;

  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DevTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DevTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DevTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.snapshot.name,
                      style: const TextStyle(
                        color: DevTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Text(
                    '${widget.snapshot.data.length} kalit',
                    style: const TextStyle(
                      color: DevTheme.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: DevTheme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: DevTheme.borderSubtle),
            Padding(
              padding: const EdgeInsets.all(12),
              child: JsonTreeView(
                data: widget.snapshot.data,
                initiallyExpanded: true,
                showCopyButton: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
