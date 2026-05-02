import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/telegram_login_button.dart';
import '../widgets/tg_login_waiting_card.dart';

/// OTP tasdiqlash ekrani.
///
/// 4 raqamli kod kiritish, 60 soniyalik countdown,
/// "Qayta yuborish" va avtomatik submit.
/// Telegram bot orqali alternativ kirish imkoniyati.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 4;
  static const int _timerSeconds = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _timerSeconds;
  Timer? _timer;
  bool _tgLaunching = false;

  // AuthProvider reference — dispose'da xavfsiz foydalanish uchun
  late final AuthProvider _authRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authRef = context.read<AuthProvider>();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Birinchi maydonni fokusga olish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _authRef.stopTgPolling();
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _timerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _currentOtp.length == _otpLength;

  Future<void> _onSubmit() async {
    if (!_isOtpComplete) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.confirmOtp(_currentOtp);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      _showSnackBar(
        auth.errorMessage ?? 'Noto\'g\'ri kod. Qayta urinib ko\'ring.',
      );
      _clearOtp();
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resendOtp(widget.phoneNumber);

    if (!mounted) return;

    if (success) {
      _startTimer();
      _clearOtp();
      _showSnackBar('Yangi kod yuborildi');
    } else {
      _showSnackBar(auth.errorMessage ?? 'Kod yuborishda xato');
    }
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Paste bo'lsa — barcha maydonlarni to'ldirish
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= _otpLength) {
        _focusNodes.last.requestFocus();
        // Avtomatik submit
        WidgetsBinding.instance.addPostFrameCallback((_) => _onSubmit());
      }
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_isOtpComplete) {
      // Avtomatik submit
      WidgetsBinding.instance.addPostFrameCallback((_) => _onSubmit());
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String get _formattedPhone {
    final phone = widget.phoneNumber;
    if (phone.length >= 13) {
      // +998 XX XXX XX XX
      return '+998 ${phone.substring(4, 6)} ${phone.substring(6, 9)} '
          '${phone.substring(9, 11)} ${phone.substring(11, 13)}';
    }
    return phone;
  }

  // ---------------------------------------------------------------------------
  // Telegram login
  // ---------------------------------------------------------------------------

  Future<void> _onTelegramLogin() async {
    setState(() => _tgLaunching = true);

    final auth = context.read<AuthProvider>();
    final session = await auth.startTgLogin(widget.phoneNumber);

    if (!mounted) return;
    setState(() => _tgLaunching = false);

    if (session == null) {
      _showSnackBar(
        auth.tgErrorMessage ?? 'Telegram sessiyasini boshlashda xatolik',
      );
      return;
    }

    // Telegram deep link'ni ochish
    final uri = Uri.tryParse(session.deepLink);
    if (uri == null) {
      _showSnackBar('Noto\'g\'ri Telegram havolasi.');
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!mounted) return;

    if (!ok) {
      _showSnackBar('Telegram ilovasi topilmadi. Iltimos, o\'rnating.');
      return;
    }

    // Polling boshlash
    auth.startTgPolling(
      onConfirmed: (user) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      },
      onFailed: (reason) {
        if (!mounted) return;
        _showSnackBar(reason);
      },
    );
  }

  void _onCancelTgPolling() {
    context.read<AuthProvider>().stopTgPolling();
  }

  /// "Hozir tekshirish" tugma — qo'lda status check qiladi.
  /// Bot kontaktni tasdiqlagan bo'lishi mumkin, lekin polling sekinlashgan.
  Future<void> _onCheckNow() async {
    final auth = context.read<AuthProvider>();
    await auth.checkTgStatusOnce(
      onConfirmed: (user) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (_) => false,
        );
      },
      onFailed: (reason) {
        if (!mounted) return;
        _showSnackBar(reason);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (auth.isTgPolling) {
                  return TgLoginWaitingCard(
                    onCancel: _onCancelTgPolling,
                    onCheckNow: _onCheckNow,
                  );
                }
                return _buildOtpContent(auth);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpContent(AuthProvider auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sms_outlined,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Kodni kiriting',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kod $_formattedPhone ga yuborildi',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // OTP kiritish maydonlari
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_otpLength, (index) {
            return Container(
              width: 56,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _onKeyEvent(index, event),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: index == 0 ? _otpLength : 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.warmBgMedium,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => _onDigitChanged(index, value),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        // Tasdiqlash tugmasi
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (auth.isLoading || !_isOtpComplete) ? null : _onSubmit,
            child: auth.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Tasdiqlash'),
          ),
        ),
        const SizedBox(height: 20),
        // Qayta yuborish
        AnimatedBuilder(
          animation: Listenable.merge(_controllers),
          builder: (_, __) => _secondsLeft > 0
              ? Text(
                  'Qayta yuborish $_secondsLeft soniyadan so\'ng',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              : GestureDetector(
                  onTap: auth.isLoading ? null : _onResend,
                  child: Text(
                    'Qayta yuborish',
                    style: TextStyle(
                      fontSize: 13,
                      color: auth.isLoading
                          ? AppColors.textSecondary
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 28),
        const _Divider(),
        const SizedBox(height: 20),
        TelegramLoginButton(
          isLoading: _tgLaunching,
          onPressed: _onTelegramLogin,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// "yoki" ajratgich
// ---------------------------------------------------------------------------

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.divider),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'yoki',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.divider),
        ),
      ],
    );
  }
}
