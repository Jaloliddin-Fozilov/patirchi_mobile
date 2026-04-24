import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:patirchi/core/dev_mode/app_logger.dart';
import 'package:patirchi/core/dev_mode/dev_mode_service.dart';
import 'package:patirchi/core/dev_mode/models/network_log_entry.dart';
import 'package:patirchi/core/dev_mode/stores/network_log_store.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/storage/secure_storage_service.dart';
import 'package:patirchi/core/theme/theme_provider.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';

/// Tezkor amallar tab.
///
/// Debugging uchun foydali amallar: logout, storage tozalash, marshrutlash va h.k.
class ActionsTab extends StatelessWidget {
  const ActionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              _ActionTile(
                icon: Icons.logout,
                label: 'Force Logout',
                description: 'Tizimdan chiqish',
                color: DevTheme.error,
                requiresConfirm: true,
                onExecute: (ctx) => _forceLogout(ctx),
              ),
              _ActionTile(
                icon: Icons.remove_shopping_cart,
                label: 'Savatni tozalash',
                description: 'Barcha mahsulotlar o\'chiriladi',
                color: DevTheme.warning,
                requiresConfirm: true,
                onExecute: (ctx) async => _clearCart(ctx),
              ),
              _ActionTile(
                icon: Icons.delete_sweep,
                label: 'Storage tozalash',
                description: 'Xavfsiz saqlash',
                color: DevTheme.error,
                requiresConfirm: true,
                twoStep: true,
                onExecute: (ctx) => _clearStorage(ctx),
              ),
              _ActionTile(
                icon: Icons.alt_route,
                label: 'Marshrutga o\'tish',
                description: 'Route nomi kiriting',
                color: DevTheme.info,
                requiresConfirm: false,
                onExecute: (ctx) => _navigateToRoute(ctx),
              ),
              _ActionTile(
                icon: Icons.brightness_6,
                label: 'Temani almashtirish',
                description: 'Light / Dark',
                color: const Color(0xFFCE93D8),
                requiresConfirm: false,
                onExecute: (ctx) async => _toggleTheme(ctx),
              ),
              _ActionTile(
                icon: Icons.text_snippet_outlined,
                label: 'Test log',
                description: 'Barcha log darajalar',
                color: DevTheme.success,
                requiresConfirm: false,
                onExecute: (ctx) async => _addTestLogs(ctx),
              ),
              _ActionTile(
                icon: Icons.lock_outline,
                label: 'Simulyatsiya 401',
                description: 'Fake 401 request',
                color: DevTheme.warning,
                requiresConfirm: false,
                onExecute: (ctx) async => _simulate401(ctx),
              ),
              _ActionTile(
                icon: Icons.power_settings_new,
                label: 'Dev mode o\'chirish',
                description: 'Debugger yopiladi',
                color: DevTheme.error,
                requiresConfirm: true,
                onExecute: (ctx) => _disableDevMode(ctx),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _forceLogout(BuildContext context) async {
    try {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  void _clearCart(BuildContext context) {
    context.read<CartProvider>().clear();
    _showSuccess(context, 'Savat tozalandi');
  }

  Future<void> _clearStorage(BuildContext context) async {
    await SecureStorageService.instance.clearAll();
    if (context.mounted) {
      _showSuccess(context, 'Storage tozalandi');
      await Future<void>.delayed(const Duration(seconds: 1));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    }
  }

  Future<void> _navigateToRoute(BuildContext context) async {
    final controller = TextEditingController();
    final route = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DevTheme.bgCard,
        title: const Text(
          'Marshrutga o\'tish',
          style: TextStyle(color: DevTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: DevTheme.mono.copyWith(color: DevTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: '/home, /profile, /settings...',
            labelText: 'Route nomi',
            labelStyle: TextStyle(color: DevTheme.textTertiary),
          ),
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
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'O\'tish',
              style: TextStyle(
                color: DevTheme.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (route != null && route.isNotEmpty && context.mounted) {
      try {
        Navigator.pushNamed(context, route);
      } catch (e) {
        _showError(context, 'Route topilmadi: $route');
      }
    }
  }

  void _toggleTheme(BuildContext context) {
    context.read<ThemeProvider>().toggleTheme();
    _showSuccess(context, 'Tema almashtirildi');
  }

  void _addTestLogs(BuildContext context) {
    AppLogger.d('Bu Debug log yozuvi', tag: 'Test');
    AppLogger.i('Bu Info log yozuvi', tag: 'Test');
    AppLogger.w('Bu Warn log yozuvi', tag: 'Test');
    AppLogger.e(
      'Bu Error log yozuvi',
      tag: 'Test',
      stackTrace: '#0 test (test.dart:1)\n#1 build (actions_tab.dart:42)',
    );
    _showSuccess(context, '4 ta test log qo\'shildi');
  }

  void _simulate401(BuildContext context) {
    const baseUrl = 'https://app.patirchi.uz/api/v1';
    final entry = NetworkLogEntry(
      id: 'sim_401_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      method: 'GET',
      url: '$baseUrl/auth/me/',
      path: '/auth/me/',
      statusCode: 401,
      duration: const Duration(milliseconds: 123),
      responseBody: const {
        'detail': 'Authentication credentials were not provided.',
      },
    );
    context.read<NetworkLogStore>().add(entry);
    _showSuccess(context, 'Simulyatsiya 401 qo\'shildi');
  }

  Future<void> _disableDevMode(BuildContext context) async {
    await DevModeService.instance.disable();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DevTheme.bgCard,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E1010),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action tile
// ---------------------------------------------------------------------------

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onExecute,
    this.requiresConfirm = true,
    this.twoStep = false,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Future<void> Function(BuildContext context) onExecute;
  final bool requiresConfirm;
  final bool twoStep;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;

    if (widget.requiresConfirm) {
      final confirmed = await _confirm();
      if (!confirmed || !mounted) return;
    }

    setState(() => _loading = true);

    final executeContext = context;
    try {
      // ignore: use_build_context_synchronously
      await widget.onExecute(executeContext);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xato: $e'),
            backgroundColor: const Color(0xFF2E1010),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DevTheme.bgCard,
        title: Text(
          widget.label,
          style: const TextStyle(color: DevTheme.textPrimary),
        ),
        content: Text(
          '${widget.description} amalga oshiriladi. Davom etasizmi?',
          style: const TextStyle(color: DevTheme.textSecondary),
        ),
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
              'Ha',
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: DevTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DevTheme.borderSubtle),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(widget.icon, size: 18, color: widget.color),
                    ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: DevTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.description,
                style: const TextStyle(
                  color: DevTheme.textTertiary,
                  fontSize: 10,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
