import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../providers/menu_provider.dart';
import '../../data/models/menu_item_model.dart';

class MenuItemFormScreen extends StatefulWidget {
  final MenuItemModel? item;

  const MenuItemFormScreen({super.key, this.item});

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _oldPriceCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _ingredientCtrl;

  late String _selectedCategory;
  late String _selectedWeightUnit;
  late List<String> _ingredients;
  late bool _isAvailable;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _priceCtrl = TextEditingController(
      text: item != null ? item.price.toString() : '',
    );
    _oldPriceCtrl = TextEditingController(
      text: item?.oldPrice?.toString() ?? '',
    );
    _weightCtrl = TextEditingController(
      text: item != null ? item.weight.toString() : '',
    );
    _ingredientCtrl = TextEditingController();
    _selectedCategory = item?.category ?? MenuProvider.fallbackCategories[1];
    _selectedWeightUnit = item?.weightUnit ?? 'kg';
    _ingredients = List<String>.from(item?.ingredients ?? []);
    _isAvailable = item?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _oldPriceCtrl.dispose();
    _weightCtrl.dispose();
    _ingredientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bakeryAccent,
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Mahsulotni tahrirlash' : "Mahsulot qo'shish"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImagePlaceholder(),
              const SizedBox(height: 20),
              _SectionTitle("Asosiy ma'lumot"),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameCtrl,
                label: 'Mahsulot nomi',
                hint: 'Masalan: Qoqon Patir',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nom kiritish shart' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descCtrl,
                label: 'Tavsif',
                hint: 'Qisqacha tavsif...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _SectionTitle('Narx'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceCtrl,
                      label: 'Narx (so\'m)',
                      hint: '5000',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Narx kiritish shart';
                        if (int.tryParse(v) == null) return "Raqam kiriting";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _oldPriceCtrl,
                      label: 'Eski narx (ixtiyoriy)',
                      hint: '6000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle('Kategoriya va og\'irlik'),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Kategoriya',
                value: _selectedCategory,
                items: MenuProvider.fallbackCategories.skip(1).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _weightCtrl,
                      label: "Og'irlik",
                      hint: '0.5',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Birlik',
                      value: _selectedWeightUnit,
                      items: const ['kg', 'g', 'dona'],
                      onChanged: (v) =>
                          setState(() => _selectedWeightUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle('Tarkib'),
              const SizedBox(height: 12),
              _IngredientsInput(
                controller: _ingredientCtrl,
                ingredients: _ingredients,
                onAdd: (ingredient) {
                  setState(() {
                    if (!_ingredients.contains(ingredient)) {
                      _ingredients = [..._ingredients, ingredient];
                    }
                    _ingredientCtrl.clear();
                  });
                },
                onRemove: (ingredient) {
                  setState(() {
                    _ingredients =
                        _ingredients.where((i) => i != ingredient).toList();
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _SectionTitle('Mavjudligi'),
                  const Spacer(),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeColor: AppColors.bakeryAccent,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bakeryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                  child: Text(
                    _isEdit ? 'Yangilash' : 'Saqlash',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.bakeryAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MenuProvider>();
    final price = int.parse(_priceCtrl.text.trim());
    final oldPriceText = _oldPriceCtrl.text.trim();
    final oldPrice =
        oldPriceText.isNotEmpty ? int.tryParse(oldPriceText) : null;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0.0;

    if (_isEdit) {
      final updated = widget.item!.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        oldPrice: oldPrice,
        category: _selectedCategory,
        weight: weight,
        weightUnit: _selectedWeightUnit,
        ingredients: _ingredients,
        isAvailable: _isAvailable,
      );
      provider.updateItem(updated);
    } else {
      final newItem = provider.createNew(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        oldPrice: oldPrice,
        category: _selectedCategory,
        weight: weight,
        weightUnit: _selectedWeightUnit,
        ingredients: _ingredients,
      );
      provider.addItem(newItem.copyWith(isAvailable: _isAvailable));
    }

    if (mounted) Navigator.pop(context);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rasm yuklash tez kunda')),
        );
      },
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.bakeryAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: AppColors.bakeryAccent.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: AppColors.bakeryAccent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Rasm yuklash',
              style: TextStyle(
                color: AppColors.bakeryAccent.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientsInput extends StatelessWidget {
  final TextEditingController controller;
  final List<String> ingredients;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _IngredientsInput({
    required this.controller,
    required this.ingredients,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Masalan: Un, Tuz...",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.isNotEmpty) onAdd(t);
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final t = controller.text.trim();
                if (t.isNotEmpty) onAdd(t);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bakeryAccent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        if (ingredients.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: ingredients
                .map(
                  (ing) => Chip(
                    label: Text(ing, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onRemove(ing),
                    backgroundColor:
                        AppColors.bakeryAccent.withValues(alpha: 0.1),
                    deleteIconColor: AppColors.bakeryAccent,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
