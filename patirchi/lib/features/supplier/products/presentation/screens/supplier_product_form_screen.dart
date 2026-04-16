import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/features/supplier/products/data/models/supplier_product_model.dart';
import 'package:patirchi/features/supplier/products/presentation/providers/supplier_products_provider.dart';
import 'package:provider/provider.dart';

class SupplierProductFormScreen extends StatefulWidget {
  final SupplierProductModel? product;

  const SupplierProductFormScreen({super.key, this.product});

  @override
  State<SupplierProductFormScreen> createState() =>
      _SupplierProductFormScreenState();
}

class _SupplierProductFormScreenState
    extends State<SupplierProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _minQtyCtrl;
  late final TextEditingController _stockCtrl;

  late String _selectedUnit;
  late String _selectedCategory;

  static const _units = ['kg', 'litr', 'dona', 'g', 'ml', 'qop'];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _minQtyCtrl = TextEditingController(text: '');
    _stockCtrl = TextEditingController(text: '');
    _selectedUnit = p?.units ?? 'kg';
    _selectedCategory =
        p?.category?.name ?? SupplierProductsProvider.categories[1];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _minQtyCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SupplierProductsProvider>();
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    final product = SupplierProductModel(
      id: widget.product?.id ?? 0,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: int.parse(_priceCtrl.text.trim()),
      units: _selectedUnit,
      isAvailable: widget.product?.isAvailable ?? true,
      isActive: widget.product?.isActive ?? true,
    );

    if (_isEditing) {
      provider.updateProduct(product);
    } else {
      provider.addProduct(product);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Mahsulot yangilandi' : "Mahsulot qo'shildi",
        ),
        backgroundColor: AppColors.supplierAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Mahsulotni tahrirlash' : "Mahsulot qo'shish"),
        backgroundColor: AppColors.supplierAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                context
                    .read<SupplierProductsProvider>()
                    .deleteProduct(widget.product!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.supplierAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: AppColors.supplierAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: AppColors.supplierAccent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rasm qo\'shish',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              AppColors.supplierAccent.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel('Asosiy ma\'lumotlar'),
              const SizedBox(height: 12),
              _buildField(
                controller: _nameCtrl,
                label: 'Mahsulot nomi',
                hint: 'Masalan: Oliy nav un',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nomni kiriting' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _descCtrl,
                label: 'Tavsif',
                hint: 'Mahsulot haqida qisqacha...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _sectionLabel('Narx va birlik'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildField(
                      controller: _priceCtrl,
                      label: 'Narx (so\'m)',
                      hint: '12000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Narxni kiriting';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Raqam kiriting';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Birlik',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.warmBg,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          items: _units
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedUnit = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionLabel('Zaxira va kategoriya'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _minQtyCtrl,
                      label: 'Min buyurtma (ixtiyoriy)',
                      hint: '50',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _stockCtrl,
                      label: 'Zaxira (${_selectedUnit})',
                      hint: '500',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Kategoriya',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SupplierProductsProvider.categories
                    .skip(1)
                    .map(
                      (cat) => GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedCategory == cat
                                ? AppColors.supplierAccent
                                : AppColors.warmBg,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusXL),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: _selectedCategory == cat
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.supplierAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Saqlash',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.warmBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide:
                  const BorderSide(color: AppColors.error),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide:
                  const BorderSide(color: AppColors.supplierAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
