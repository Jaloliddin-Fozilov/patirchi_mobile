import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/section_card.dart';
import 'package:patirchi/core/network/api_client.dart';
import 'package:patirchi/core/network/api_config.dart';
import 'package:patirchi/core/network/api_endpoints.dart';

/// API konfiguratsiya tab.
///
/// Base URL ni o'zgartirish va health check imkoniyatini beradi.
class ApiTab extends StatefulWidget {
  const ApiTab({super.key});

  @override
  State<ApiTab> createState() => _ApiTabState();
}

class _ApiTabState extends State<ApiTab> {
  late String _selectedPreset;
  final _customUrlController = TextEditingController();
  bool _healthChecking = false;
  _HealthCheckResult? _healthResult;

  @override
  void initState() {
    super.initState();
    _selectedPreset = ApiConfig.instance.currentPreset;
    if (_selectedPreset == 'custom') {
      _customUrlController.text = ApiConfig.instance.baseUrl;
    }
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  void _applyConfig() {
    if (_selectedPreset == 'custom') {
      final url = _customUrlController.text.trim();
      if (url.isEmpty) return;
      ApiConfig.instance.baseUrl = url;
    } else {
      ApiConfig.instance.applyPreset(_selectedPreset);
    }

    setState(() => _healthResult = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base URL yangilandi: ${ApiConfig.instance.baseUrl}'),
        backgroundColor: DevTheme.bgCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _runHealthCheck() async {
    setState(() {
      _healthChecking = true;
      _healthResult = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      final result = await ApiClient.instance.get(ApiEndpoints.me);
      stopwatch.stop();

      setState(() {
        _healthResult = _HealthCheckResult(
          success: true,
          statusCode: 200,
          durationMs: stopwatch.elapsedMilliseconds,
          preview: result.toString().length > 100
              ? '${result.toString().substring(0, 100)}...'
              : result.toString(),
        );
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _healthResult = _HealthCheckResult(
          success: false,
          statusCode: null,
          durationMs: stopwatch.elapsedMilliseconds,
          preview: e.toString(),
        );
      });
    } finally {
      setState(() => _healthChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current URL
          SectionCard(
            title: 'JORIY BASE URL',
            trailing: GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: ApiConfig.instance.baseUrl),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nusxalandi'),
                    duration: Duration(seconds: 1),
                    backgroundColor: DevTheme.bgCard,
                  ),
                );
              },
              child: const Icon(
                Icons.copy,
                size: 16,
                color: DevTheme.textTertiary,
              ),
            ),
            child: Text(
              ApiConfig.instance.baseUrl,
              style: DevTheme.mono.copyWith(
                fontSize: 12,
                color: DevTheme.accent,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Preset selection
          SectionCard(
            title: 'MUHIT TANLASH',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final preset in [
                  ...ApiConfig.presets.keys,
                  'custom',
                ])
                  _PresetRadio(
                    preset: preset,
                    url: ApiConfig.presets[preset] ?? 'Maxsus URL',
                    selected: _selectedPreset == preset,
                    onTap: () => setState(() {
                      _selectedPreset = preset;
                      _healthResult = null;
                    }),
                  ),
                if (_selectedPreset == 'custom') ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _customUrlController,
                    style: DevTheme.mono.copyWith(
                      fontSize: 12,
                      color: DevTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/api/v1',
                      labelText: 'Maxsus URL',
                      labelStyle: TextStyle(
                        color: DevTheme.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DevTheme.accentDim,
                      foregroundColor: DevTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Qo\'llash',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Health check
          SectionCard(
            title: 'HEALTH CHECK',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GET ${ApiEndpoints.me}',
                  style: DevTheme.mono.copyWith(
                    fontSize: 11,
                    color: DevTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _healthChecking ? null : _runHealthCheck,
                    icon: _healthChecking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                DevTheme.textPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.health_and_safety_outlined, size: 16),
                    label: Text(_healthChecking ? 'Tekshirilmoqda...' : 'Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DevTheme.bgTertiary,
                      foregroundColor: DevTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(
                          color: DevTheme.borderSubtle,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_healthResult != null) ...[
                  const SizedBox(height: 10),
                  _HealthResultCard(result: _healthResult!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preset radio
// ---------------------------------------------------------------------------

class _PresetRadio extends StatelessWidget {
  const _PresetRadio({
    required this.preset,
    required this.url,
    required this.selected,
    required this.onTap,
  });

  final String preset;
  final String url;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? DevTheme.accent : DevTheme.borderSubtle,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: DevTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset,
                  style: TextStyle(
                    color: selected ? DevTheme.textPrimary : DevTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Text(
                  url,
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

// ---------------------------------------------------------------------------
// Health check result
// ---------------------------------------------------------------------------

class _HealthCheckResult {
  const _HealthCheckResult({
    required this.success,
    required this.statusCode,
    required this.durationMs,
    required this.preview,
  });

  final bool success;
  final int? statusCode;
  final int durationMs;
  final String preview;
}

class _HealthResultCard extends StatelessWidget {
  const _HealthResultCard({required this.result});

  final _HealthCheckResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.success ? DevTheme.success : DevTheme.error;
    final icon = result.success ? Icons.check_circle_outline : Icons.error_outline;
    final label = result.success ? 'Muvaffaqiyatli' : 'Xato';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${result.durationMs}ms',
                style: DevTheme.mono.copyWith(
                  fontSize: 12,
                  color: DevTheme.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.preview,
            style: DevTheme.mono.copyWith(
              fontSize: 11,
              color: DevTheme.textSecondary,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
