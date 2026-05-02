import 'package:flutter/material.dart';
import 'package:patirchi/core/theme/app_colors.dart';

/// Telegram polling holatida ko'rsatiluvchi kutish kartasi.
///
/// Pulsatsiyalanuvchi animatsiya, holat matni, bekor qilish va
/// "Tekshirish" tugmalari (agar polling ishlamasa user qo'lda check qila oladi).
class TgLoginWaitingCard extends StatefulWidget {
  const TgLoginWaitingCard({
    super.key,
    required this.onCancel,
    this.onCheckNow,
    this.statusMessage,
  });

  final VoidCallback onCancel;

  /// "Hozir tekshirish" tugmasi — qo'lda status check uchun.
  final VoidCallback? onCheckNow;

  final String? statusMessage;

  @override
  State<TgLoginWaitingCard> createState() => _TgLoginWaitingCardState();
}

class _TgLoginWaitingCardState extends State<TgLoginWaitingCard>
    with SingleTickerProviderStateMixin {
  static const Color _tgBlue = Color(0xFF229ED9);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pulsatsiyalanuvchi icon
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final scale = 1.0 + 0.15 * _controller.value;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _tgBlue.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _tgBlue,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Telegram\'da kutilmoqda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.statusMessage ??
              'Botda telefon raqamingizni ulashing,\n'
                  'avtomatik kiritamiz.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _tgBlue,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.onCheckNow != null) ...[
          OutlinedButton.icon(
            onPressed: widget.onCheckNow,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Hozir tekshirish'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _tgBlue,
              side: const BorderSide(color: _tgBlue),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Bekor qilish'),
        ),
      ],
    );
  }
}
