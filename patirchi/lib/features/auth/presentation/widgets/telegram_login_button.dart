import 'package:flutter/material.dart';

/// Telegram brand asoslangan chiroyli login tugmasi.
///
/// Gradient ko'k rang, paper plane icon — Telegram logosi shaklida.
class TelegramLoginButton extends StatelessWidget {
  const TelegramLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Telegram bot orqali kirish',
    this.subtitle = 'Kod kelmadimi? Oson va tezkor',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final String subtitle;

  static const Color _telegramBlue = Color(0xFF229ED9);
  static const Color _telegramBlueDark = Color(0xFF0088CC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: _telegramBlue.withValues(alpha: 0.2),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_telegramBlue, _telegramBlueDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _telegramBlue.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                // Telegram paper plane icon (circular white bg)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _telegramBlue,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: _telegramBlue,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
