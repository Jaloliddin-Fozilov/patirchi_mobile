import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import '../providers/menu_provider.dart';
import '../../data/models/menu_item_model.dart';
import 'menu_item_form_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  bool _isGrid = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, provider, _) {
        final items = provider.filteredItems;
        return Column(
          children: [
            _SearchBar(
              controller: _searchController,
              onChanged: provider.setSearch,
              isGrid: _isGrid,
              onToggleView: () => setState(() => _isGrid = !_isGrid),
            ),
            _CategoryRow(provider: provider),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.bakery_dining_outlined,
                      title: 'Mahsulot topilmadi',
                      subtitle: "Qidiruv so'zini o'zgartiring yoki yangi mahsulot qo'shing",
                    )
                  : _isGrid
                      ? _GridView(items: items, provider: provider)
                      : _ListView(items: items, provider: provider),
            ),
          ],
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, {MenuItemModel? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuItemFormScreen(item: item),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return Scaffold(
      body: build(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        backgroundColor: AppColors.bakeryAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Mahsulot qo'shish"),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isGrid;
  final VoidCallback onToggleView;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.isGrid,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Mahsulot qidirish...',
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
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onToggleView,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bakeryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(
                isGrid ? Icons.list : Icons.grid_view,
                color: AppColors.bakeryAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final MenuProvider provider;
  const _CategoryRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = provider.categories[i];
          final isSelected = provider.selectedCategory == cat;
          return GestureDetector(
            onTap: () => provider.setCategory(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.bakeryAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.bakeryAccent : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  final List<MenuItemModel> items;
  final MenuProvider provider;

  const _GridView({required this.items, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _MenuGridCard(
        item: items[i],
        provider: provider,
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List<MenuItemModel> items;
  final MenuProvider provider;

  const _ListView({required this.items, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _MenuListCard(
        item: items[i],
        provider: provider,
      ),
    );
  }
}

class _MenuGridCard extends StatelessWidget {
  final MenuItemModel item;
  final MenuProvider provider;

  const _MenuGridCard({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openForm(context),
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.bakeryAccent.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.bakery_dining,
                  size: 48,
                  color: AppColors.bakeryAccent.withValues(alpha: 0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.price(item.price),
                    style: const TextStyle(
                      color: AppColors.bakeryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.isAvailable ? 'Mavjud' : 'Mavjud emas',
                          style: TextStyle(
                            color: item.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => provider.toggleAvailability(item.id),
                        child: Icon(
                          item.isAvailable
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: item.isAvailable
                              ? AppColors.success
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuItemFormScreen(item: item),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("O'chirish"),
        content: Text("${item.name}ni o'chirmoqchimisiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}

class _MenuListCard extends StatelessWidget {
  final MenuItemModel item;
  final MenuProvider provider;

  const _MenuListCard({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("O'chirish"),
            content: Text("${item.name}ni o'chirmoqchimisiz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Bekor'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text("O'chirish"),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteItem(item.id),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuItemFormScreen(item: item)),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bakeryAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  Icons.bakery_dining,
                  color: AppColors.bakeryAccent.withValues(alpha: 0.4),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.price(item.price),
                      style: const TextStyle(
                        color: AppColors.bakeryAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.isAvailable,
                onChanged: (_) => provider.toggleAvailability(item.id),
                activeColor: AppColors.bakeryAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
