import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const PhoneInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(AppConstants.phoneLength),
        _PhoneFormatter(),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+998',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                height: 24,
                child: VerticalDivider(color: AppColors.border, width: 1),
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
        hintText: '90 123 45 67',
        errorText: errorText,
      ),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}