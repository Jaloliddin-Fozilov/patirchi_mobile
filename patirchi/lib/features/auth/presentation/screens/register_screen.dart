import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/widgets/phone_input.dart';
import 'package:patirchi/core/utils/validators.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(' ', '');
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (Validators.required(name) != null) {
      _showError('Ismingizni kiriting');
      return;
    }
    if (Validators.phone(phone) != null) {
      _showError('Telefon raqamni to\'g\'ri kiriting');
      return;
    }
    if (Validators.password(password) != null) {
      _showError('Parol kamida 4 ta belgi bo\'lishi kerak');
      return;
    }
    if (password != confirm) {
      _showError('Parollar mos kelmadi');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(name, phone, password);
    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                const Icon(Icons.bakery_dining, size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  'Ro\'yxatdan o\'tish',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ismingiz',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 14),
                PhoneInput(controller: _phoneController),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    hintText: 'Parol',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    hintText: 'Parolni tasdiqlang',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ro\'yxatdan o\'tish'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Akkauntingiz bormi? ',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Kirish',
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
