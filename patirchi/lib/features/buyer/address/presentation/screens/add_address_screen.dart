import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/features/buyer/address/data/models/address_model.dart';
import 'package:patirchi/features/buyer/address/presentation/providers/address_provider.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? existingAddress;

  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _label;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _buildingCtrl;
  late final TextEditingController _apartmentCtrl;
  late final TextEditingController _floorCtrl;
  late final TextEditingController _entranceCtrl;
  late final TextEditingController _commentCtrl;

  static const _labels = ['Uy', 'Ish', 'Boshqa'];

  @override
  void initState() {
    super.initState();
    final e = widget.existingAddress;
    _label = e?.label ?? 'Uy';
    _streetCtrl = TextEditingController(text: e?.street ?? '');
    _buildingCtrl = TextEditingController(text: e?.building ?? '');
    _apartmentCtrl = TextEditingController(text: e?.apartment ?? '');
    _floorCtrl = TextEditingController(text: e?.floor ?? '');
    _entranceCtrl = TextEditingController(text: e?.entrance ?? '');
    _commentCtrl = TextEditingController(text: e?.comment ?? '');
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _apartmentCtrl.dispose();
    _floorCtrl.dispose();
    _entranceCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddressProvider>();
    final address = AddressModel(
      id: widget.existingAddress?.id ?? '',
      label: _label,
      street: _streetCtrl.text.trim(),
      building: _buildingCtrl.text.trim(),
      apartment: _apartmentCtrl.text.trim().isNotEmpty
          ? _apartmentCtrl.text.trim()
          : null,
      floor: _floorCtrl.text.trim().isNotEmpty
          ? _floorCtrl.text.trim()
          : null,
      entrance: _entranceCtrl.text.trim().isNotEmpty
          ? _entranceCtrl.text.trim()
          : null,
      comment: _commentCtrl.text.trim().isNotEmpty
          ? _commentCtrl.text.trim()
          : null,
      isDefault: widget.existingAddress?.isDefault ?? false,
    );

    if (widget.existingAddress != null) {
      provider.updateAddress(address);
    } else {
      provider.addAddress(address);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingAddress != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Manzilni tahrirlash' : 'Yangi manzil',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label chips
                    _FormCard(
                      title: 'Manzil turi',
                      child: Row(
                        children: _labels.map((label) {
                          final isSelected = _label == label;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _label = label),
                              child: AnimatedContainer(
                                duration: AppConstants.animFast,
                                margin: EdgeInsets.only(
                                  right: label != _labels.last ? 8 : 0,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusM,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _labelIcon(label),
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Main address fields
                    _FormCard(
                      title: 'Ko\'cha va uy',
                      child: Column(
                        children: [
                          _InputField(
                            controller: _streetCtrl,
                            label: 'Ko\'cha nomi *',
                            hint: 'Masalan: Chilonzor ko\'chasi',
                            icon: Icons.signpost_outlined,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Ko\'cha nomini kiriting'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: _buildingCtrl,
                                  label: 'Uy raqami *',
                                  hint: '12',
                                  icon: Icons.home_outlined,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Uy raqami'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InputField(
                                  controller: _apartmentCtrl,
                                  label: 'Kvartira',
                                  hint: '45',
                                  icon: Icons.apartment_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Additional details
                    _FormCard(
                      title: 'Qo\'shimcha ma\'lumotlar',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  controller: _floorCtrl,
                                  label: 'Qavat',
                                  hint: '4',
                                  icon: Icons.layers_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InputField(
                                  controller: _entranceCtrl,
                                  label: 'Kirish',
                                  hint: '2',
                                  icon: Icons.door_front_door_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _InputField(
                            controller: _commentCtrl,
                            label: 'Izoh',
                            hint: 'Kuryer uchun qo\'shimcha izoh...',
                            icon: Icons.comment_outlined,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEdit ? 'Saqlash' : 'Manzil qo\'shish',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _labelIcon(String label) {
    return switch (label) {
      'Uy' => Icons.home_rounded,
      'Ish' => Icons.work_rounded,
      _ => Icons.location_on_rounded,
    };
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.warmBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
