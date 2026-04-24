import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/json_tree_view.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/section_card.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/status_chip.dart';

/// Bitta network so'rovining to'liq detallarini ko'rsatuvchi ekran.
class NetworkDetailScreen extends StatelessWidget {
  const NetworkDetailScreen({super.key, required this.entry});

  final NetworkLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: DevTheme.themeData,
      child: Scaffold(
        backgroundColor: DevTheme.bgPrimary,
        appBar: AppBar(
          backgroundColor: DevTheme.bgSecondary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: DevTheme.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              StatusChip.method(entry.method),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.path,
                  style: const TextStyle(
                    color: DevTheme.textPrimary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _buildOverview(context),
            const SizedBox(height: 12),
            _buildQueryParams(),
            const SizedBox(height: 12),
            _buildRequestBody(),
            const SizedBox(height: 12),
            _buildResponseBody(context),
            const SizedBox(height: 12),
            _buildCurl(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Overview
  // ---------------------------------------------------------------------------

  Widget _buildOverview(BuildContext context) {
    final duration = entry.duration != null
        ? '${entry.duration!.inMilliseconds}ms'
        : '(davom etmoqda)';

    return SectionCard(
      title: 'UMUMIY',
      child: Column(
        children: [
          _InfoRow(
            label: 'Method',
            value: entry.method,
            valueWidget: StatusChip.method(entry.method),
          ),
          _InfoRow(
            label: 'URL',
            value: entry.url,
            copyable: true,
            mono: true,
          ),
          _InfoRow(
            label: 'Status',
            value: entry.statusCode?.toString() ?? '---',
            valueWidget: StatusChip.status(entry.statusCode),
          ),
          _InfoRow(label: 'Davomiyligi', value: duration),
          _InfoRow(
            label: 'Vaqt',
            value: entry.timestamp.toLocal().toString(),
          ),
          if (entry.errorMessage != null)
            _InfoRow(
              label: 'Xato',
              value: entry.errorMessage!,
              valueColor: DevTheme.error,
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Query params
  // ---------------------------------------------------------------------------

  Widget _buildQueryParams() {
    return SectionCard(
      title: 'QUERY PARAMS',
      child: entry.queryParams == null || entry.queryParams!.isEmpty
          ? const Text(
              'Yo\'q',
              style: TextStyle(color: DevTheme.textTertiary, fontSize: 12),
            )
          : JsonTreeView(data: entry.queryParams, showCopyButton: false),
    );
  }

  // ---------------------------------------------------------------------------
  // Request body
  // ---------------------------------------------------------------------------

  Widget _buildRequestBody() {
    return SectionCard(
      title: 'REQUEST BODY',
      child: entry.requestBody == null || entry.requestBody!.isEmpty
          ? const Text(
              'Yo\'q',
              style: TextStyle(color: DevTheme.textTertiary, fontSize: 12),
            )
          : JsonTreeView(data: entry.requestBody, showCopyButton: false),
    );
  }

  // ---------------------------------------------------------------------------
  // Response body
  // ---------------------------------------------------------------------------

  Widget _buildResponseBody(BuildContext context) {
    return SectionCard(
      title: 'RESPONSE BODY',
      trailing: entry.responseBody != null
          ? GestureDetector(
              onTap: () => _copyJson(context, entry.responseBody),
              child: const Icon(
                Icons.copy,
                size: 16,
                color: DevTheme.textTertiary,
              ),
            )
          : null,
      child: entry.responseBody == null || entry.responseBody!.isEmpty
          ? const Text(
              'Yo\'q',
              style: TextStyle(color: DevTheme.textTertiary, fontSize: 12),
            )
          : JsonTreeView(
              data: entry.responseBody,
              showCopyButton: false,
              initiallyExpanded: true,
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // cURL
  // ---------------------------------------------------------------------------

  Widget _buildCurl(BuildContext context) {
    final curl = _buildCurlCommand();

    return SectionCard(
      title: 'cURL',
      trailing: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: curl));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('cURL nusxalandi'),
              duration: Duration(seconds: 1),
              backgroundColor: DevTheme.bgCard,
            ),
          );
        },
        child: const Icon(Icons.copy, size: 16, color: DevTheme.textTertiary),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          curl,
          style: DevTheme.mono.copyWith(
            fontSize: 11,
            color: DevTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  String _buildCurlCommand() {
    final buffer = StringBuffer();
    buffer.write('curl -X ${entry.method}');

    // Headers
    final headers = entry.requestHeaders ?? {};
    for (final h in headers.entries) {
      buffer.write(" \\\n  -H '${h.key}: ${h.value}'");
    }

    // Body
    if (entry.requestBody != null && entry.requestBody!.isNotEmpty) {
      final bodyStr = entry.requestBody.toString().replaceAll("'", '"');
      buffer.write(" \\\n  -d '$bodyStr'");
    }

    // URL with query params
    var url = entry.url;
    if (entry.queryParams != null && entry.queryParams!.isNotEmpty) {
      final params = entry.queryParams!.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      url = '$url?$params';
    }

    buffer.write(" \\\n  '$url'");
    return buffer.toString();
  }

  void _copyJson(BuildContext context, dynamic data) {
    try {
      Clipboard.setData(ClipboardData(text: data.toString()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nusxalandi'),
          duration: Duration(seconds: 1),
          backgroundColor: DevTheme.bgCard,
        ),
      );
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
    this.copyable = false,
    this.mono = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget? valueWidget;
  final bool copyable;
  final bool mono;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: DevTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: (mono ? DevTheme.mono : const TextStyle()).copyWith(
                    color: valueColor ?? DevTheme.textPrimary,
                    fontSize: 12,
                  ),
                ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nusxalandi'),
                    duration: Duration(seconds: 1),
                    backgroundColor: DevTheme.bgCard,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: DevTheme.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
