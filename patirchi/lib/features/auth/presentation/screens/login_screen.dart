import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/phone_input.dart';
import '../providers/auth_provider.dart';

/// OTP asosidagi kirish ekrani.
///
/// Foydalanuvchi telefon raqamini kiritadi → "Kirish" bosadi →
/// backend OTP yuboradi → OTP ekraniga o'tish.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.isEmpty) {
      _showSnackBar('Telefon raqamingizni kiriting');
      return;
    }

    // +998 prefixi qo'shilganligini tekshir
    final fullPhone = phone.startsWith('+998') ? phone : '+998$phone';
    if (fullPhone.length != 13) {
      _showSnackBar('Telefon raqami noto\'g\'ri. Format: +998XXXXXXXXX');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(fullPhone);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: fullPhone,
      );
    } else {
      _showSnackBar(auth.errorMessage ?? 'Xato yuz berdi');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBg,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bakery_dining,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'PATIRCHI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tizimga xush kelibsiz',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) {
                    final roleLabel = auth.selectedRole == 'business'
                        ? 'Biznes hisob'
                        : 'Oddiy foydalanuvchi';
                    return Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Telefon raqamingiz',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                PhoneInput(controller: _phoneController),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SMS orqali tasdiqlash kodi yuboriladi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _onLoginPressed,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Kirish'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Akkauntingiz yo\'qmi? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Ro\'yxatdan o\'tish',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
