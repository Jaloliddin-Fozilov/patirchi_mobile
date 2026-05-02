import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import 'package:patirchi/core/utils/formatters.dart';
import 'package:patirchi/core/widgets/empty_state.dart';
import 'package:patirchi/features/courier/deliveries/data/models/delivery_model.dart';
import 'package:patirchi/features/courier/deliveries/presentation/providers/courier_provider.dart';
import 'package:patirchi/features/courier/deliveries/presentation/screens/delivery_detail_screen.dart';

class CourierDeliveriesScreen extends StatelessWidget {
  const CourierDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourierProvider>();
    final isOnline = provider.isOnline;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online / Offline toggle
            _OnlineToggle(
              isOnline: isOnline,
              onToggle: provider.toggleOnline,
            ),
            const SizedBox(height: 20),

            if (!isOnline) ...[
              const EmptyState(
                icon: Icons.delivery_dining,
                title: 'Siz oflayn rejimdasiz',
                subtitle:
                    "Buyurtmalarni ko'rish va qabul qilish uchun onlayn bo'ling",
              ),
            ] else ...[
              // Stats row
              _StatsRow(provider: provider),
              const SizedBox(height: 20),

              // Active deliveries
              if (provider.myActiveDeliveries.isNotEmpty) ...[
                _sectionHeader('Faol yetkazuvlar', AppColors.primary),
                const SizedBox(height: 10),
                ...provider.myActiveDeliveries.map(
                  (d) => _DeliveryCard(
                    delivery: d,
                    isActive: true,
                    onTap: () => _openDetail(context, d.id),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Available deliveries
              _sectionHeader(
                'Mavjud buyurtmalar (${provider.availableDeliveries.length})',
                AppColors.textSecondary,
              ),
              const SizedBox(height: 10),
              if (provider.availableDeliveries.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  child: const Text(
                    "Hozircha yangi buyurtmalar yo'q",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                ...provider.availableDeliveries.map(
                  (d) => _DeliveryCard(
                    delivery: d,
                    isActive: false,
                    onTap: () => _openDetail(context, d.id),
                    onAccept: () async {
                      final success =
                          await context.read<CourierProvider>().acceptDelivery(
                                d.id,
                              );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Buyurtma qabul qilindi'
                                  : 'Xatolik yuz berdi',
                            ),
                            backgroundColor:
                                success ? AppColors.primary : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<CourierProvider>(),
          child: DeliveryDetailScreen(deliveryId: id),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: color,
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const _OnlineToggle({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [AppColors.primary, AppColors.primaryLight]
              : [AppColors.textSecondary, const Color(0xFF9E9E9E)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.primary : AppColors.textSecondary)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.delivery_dining : Icons.power_settings_new,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Siz onlayn' : 'Siz oflayn',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isOnline
                      ? "Yangi buyurtmalarni ko'ryapsiz"
                      : 'Bosing va ishlashni boshlang',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: (_) => onToggle(),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final CourierProvider provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          value: provider.todayDeliveryCount.toString(),
          label: 'Bugungi',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        _StatBox(
          value: Formatters.priceShort(provider.todayEarnings),
          label: 'Daromad',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(width: 12),
        _StatBox(
          value: provider.myActiveDeliveries.length.toString(),
          label: 'Faol',
          icon: Icons.local_shipping_outlined,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final DeliveryOrderModel delivery;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onAccept;

  const _DeliveryCard({
    required this.delivery,
    required this.isActive,
    required this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Order id & fee
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buyurtma #${delivery.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              delivery.distanceLabel.isNotEmpty
                                  ? delivery.distanceLabel
                                  : delivery.statusLabel,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusXL),
                        ),
                        child: Text(
                          Formatters.price(delivery.deliveryFee),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Route
                  _RouteRow(
                    icon: Icons.store_outlined,
                    label: 'Olish',
                    name: delivery.storeName,
                    address: delivery.storeAddress,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    width: 1,
                    height: 16,
                    color: AppColors.divider,
                  ),
                  _RouteRow(
                    icon: Icons.location_on_outlined,
                    label: 'Yetkazish',
                    name: delivery.customerPhone,
                    address: delivery.notes ?? '',
                    iconColor: AppColors.error,
                  ),
                ],
              ),
            ),
            if (!isActive && onAccept != null)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: TextButton(
                  onPressed: onAccept,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppConstants.radiusL),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Qabul qilish',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            if (isActive)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppConstants.radiusL),
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation_outlined, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Batafsil ko'rish",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String address;
  final Color iconColor;

  const _RouteRow({
    required this.icon,
    required this.label,
    required this.name,
    required this.address,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (address.isNotEmpty)
                Text(
                  address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
