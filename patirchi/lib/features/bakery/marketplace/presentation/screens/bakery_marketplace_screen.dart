import 'package:flutter/material.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';

class _SupplierProduct {
  final String id;
  final String productName;
  final String supplierName;
  final int pricePerUnit;
  final int minOrderQty;
  final String unit;
  final String category;
  final String description;

  const _SupplierProduct({
    required this.id,
    required this.productName,
    required this.supplierName,
    required this.pricePerUnit,
    required this.minOrderQty,
    required this.unit,
    required this.category,
    required this.description,
  });
}

const _mockProducts = [
  _SupplierProduct(
    id: '1',
    productName: 'Premium Un (1-nav)',
    supplierName: 'Toshkent Tegirmon',
    pricePerUnit: 8500,
    minOrderQty: 25,
    unit: 'kg',
    category: 'Un',
    description: "Yuqori sifatli bug'doy uni, 1-navli",
  ),
  _SupplierProduct(
    id: '2',
    productName: 'Un (2-nav)',
    supplierName: 'Samarqand Tegirmon',
    pricePerUnit: 6500,
    minOrderQty: 50,
    unit: 'kg',
    category: 'Un',
    description: '2-nav un, non va somsa uchun',
  ),
  _SupplierProduct(
    id: '3',
    productName: 'Shakar (oq)',
    supplierName: "O'zbekiston Shakar",
    pricePerUnit: 12000,
    minOrderQty: 10,
    unit: 'kg',
    category: 'Shakar',
    description: "Tozalangan oq shakar, to'g'ridan-to'g'ri zavod",
  ),
  _SupplierProduct(
    id: '4',
    productName: "Paxta yog'i (rafinirlangan)",
    supplierName: 'Andijon Yog\'i',
    pricePerUnit: 15000,
    minOrderQty: 5,
    unit: 'litr',
    category: "Yog'",
    description: "Rafinirlangan paxta yog'i",
  ),
  _SupplierProduct(
    id: '5',
    productName: "Qo'y yog'i (erigan)",
    supplierName: 'Fermer Mahsulotlari',
    pricePerUnit: 45000,
    minOrderQty: 2,
    unit: 'kg',
    category: "Yog'",
    description: "Toza qo'y yog'i, patir uchun ideal",
  ),
  _SupplierProduct(
    id: '6',
    productName: 'Quruq xamirturush',
    supplierName: 'Import Mahsulotlar',
    pricePerUnit: 8000,
    minOrderQty: 1,
    unit: 'kg',
    category: 'Boshqa',
    description: "Aktiv quruq xamirturush, 11g'li paketlarda",
  ),
  _SupplierProduct(
    id: '7',
    productName: 'Sedana (zira)',
    supplierName: 'Qashqadaryo Ziravorlari',
    pricePerUnit: 18000,
    minOrderQty: 1,
    unit: 'kg',
    category: 'Ziravorlar',
    description: 'Toza sedana, nonvoyxona uchun',
  ),
  _SupplierProduct(
    id: '8',
    productName: 'Tuxum (tovuq)',
    supplierName: "Parrandachilik Ferma",
    pricePerUnit: 1200,
    minOrderQty: 30,
    unit: 'dona',
    description: 'Yangi tovuq tuxumi',
    category: 'Sut mahsulotlari',
  ),
  _SupplierProduct(
    id: '9',
    productName: 'Toza sut (pasterizatsiyalangan)',
    supplierName: 'Fermer Suti',
    pricePerUnit: 6000,
    minOrderQty: 5,
    unit: 'litr',
    category: 'Sut mahsulotlari',
    description: 'Yangi pasterizatsiyalangan sut',
  ),
  _SupplierProduct(
    id: '10',
    productName: 'Tuz (mayda)',
    supplierName: 'Toshkent Kimyo',
    pricePerUnit: 2000,
    minOrderQty: 10,
    unit: 'kg',
    category: 'Boshqa',
    description: 'Oshxona tuzi, yodlangan',
  ),
];

const _categories = [
  'Barchasi',
  'Un',
  'Shakar',
  "Yog'",
  'Sut mahsulotlari',
  'Ziravorlar',
  'Boshqa',
];

class BakeryMarketplaceScreen extends StatefulWidget {
  const BakeryMarketplaceScreen({super.key});

  @override
  State<BakeryMarketplaceScreen> createState() =>
      _BakeryMarketplaceScreenState();
}

class _BakeryMarketplaceScreenState extends State<BakeryMarketplaceScreen> {
  String _selectedCategory = 'Barchasi';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_SupplierProduct> get _filteredProducts {
    var result = _mockProducts.toList();
    if (_selectedCategory != 'Barchasi') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.productName.toLowerCase().contains(q) ||
              p.supplierName.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              const Row(
                children: [
                  Text(
                    "Ta'minotchilar Bozori",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Mahsulot yoki ta\'minotchi qidirish...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.bakeryAccent
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.bakeryAccent
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Mahsulot topilmadi',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _ProductCard(product: _filteredProducts[i]),
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final _SupplierProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bakeryAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.bakeryAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.supplierName,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  product.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Formatters.price(product.pricePerUnit)} / ${product.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.bakeryAccent,
                    ),
                  ),
                  Text(
                    'Min buyurtma: ${product.minOrderQty} ${product.unit}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showOrderDialog(context),
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text('Buyurtma'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bakeryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    final controller = TextEditingController(
      text: product.minOrderQty.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(product.productName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${product.supplierName}dan buyurtma',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Miqdor (${product.unit})",
                suffixText: product.unit,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Min: ${product.minOrderQty} ${product.unit}",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${product.productName} buyurtmasi yuborildi"),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bakeryAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buyurtma berish'),
          ),
        ],
      ),
    );
  }
}
