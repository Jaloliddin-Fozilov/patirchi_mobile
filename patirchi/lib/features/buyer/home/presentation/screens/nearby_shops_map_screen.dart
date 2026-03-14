import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../../data/datasources/buyer_home_local_datasource.dart';
import '../../data/models/shop_model.dart';
import 'shop_detail_screen.dart';

class NearbyShopsMapScreen extends StatefulWidget {
  const NearbyShopsMapScreen({super.key});

  @override
  State<NearbyShopsMapScreen> createState() => _NearbyShopsMapScreenState();
}

class _NearbyShopsMapScreenState extends State<NearbyShopsMapScreen> {
  YandexMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageController;

  List<ShopModel> _shops = [];
  List<ShopModel> _filteredShops = [];
  int _selectedIndex = 0;
  bool _isPageAnimating = false;

  // Marker icon cache
  Uint8List? _markerNormal;
  Uint8List? _markerSelected;

  static const _tashkentCenter = Point(latitude: 41.3111, longitude: 69.2797);
  static const double _defaultZoom = 12.5;
  static const double _focusZoom = 15.0;

  // ──────────────────────────── Lifecycle ────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _loadShops();
    _generateMarkerIcons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _loadShops() {
    _shops = BuyerHomeLocalDatasource.shops
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
    _filteredShops = List.from(_shops);
  }

  Future<void> _generateMarkerIcons() async {
    _markerNormal = await _renderMarkerPng(size: 96, selected: false);
    _markerSelected = await _renderMarkerPng(size: 112, selected: true);
    if (mounted) setState(() {});
  }

  // ──────────────────────────── Marker Icon Rendering ────────────────────────────

  static Future<Uint8List> _renderMarkerPng({
    required double size,
    required bool selected,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

    final center = Offset(size / 2, size / 2 - 4);
    final radius = size * 0.36;
    final borderWidth = selected ? 4.0 : 3.0;

    // Drop shadow
    canvas.drawCircle(
      Offset(center.dx, center.dy + 3),
      radius + 2,
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Main circle fill
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = selected ? AppColors.primary : const Color(0xFFFA6400),
    );

    // White border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Bread icon (simplified oval + scoring lines)
    final iconW = radius * 0.9;
    final iconH = radius * 0.6;
    final iconRect = Rect.fromCenter(
      center: center,
      width: iconW,
      height: iconH,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(iconRect, Radius.circular(iconH * 0.4)),
      Paint()..color = Colors.white,
    );

    // Scoring lines on bread
    final scorePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final dx in [-0.2, 0.0, 0.2]) {
      canvas.drawLine(
        Offset(center.dx + iconW * dx, center.dy - iconH * 0.22),
        Offset(center.dx + iconW * dx, center.dy + iconH * 0.22),
        scorePaint,
      );
    }

    // Bottom pointer (triangle)
    final pointerPath = Path()
      ..moveTo(center.dx - 8, center.dy + radius - 2)
      ..lineTo(center.dx, center.dy + radius + 10)
      ..lineTo(center.dx + 8, center.dy + radius - 2)
      ..close();
    canvas.drawPath(
      pointerPath,
      Paint()..color = selected ? AppColors.primary : const Color(0xFFFA6400),
    );
    // White edge on pointer
    canvas.drawPath(
      pointerPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 0.6,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // ──────────────────────────── Map Objects ────────────────────────────

  List<PlacemarkMapObject> _buildPlacemarks() {
    if (_markerNormal == null || _markerSelected == null) return [];

    return _filteredShops.asMap().entries.map((entry) {
      final index = entry.key;
      final shop = entry.value;
      final isSelected = index == _selectedIndex;

      return PlacemarkMapObject(
        mapId: MapObjectId('shop_${shop.id}'),
        point: Point(latitude: shop.latitude!, longitude: shop.longitude!),
        opacity: 1.0,
        zIndex: isSelected ? 10 : 0,
        consumeTapEvents: true,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(
              isSelected ? _markerSelected! : _markerNormal!,
            ),
            scale: isSelected ? 0.55 : 0.45,
            anchor: const Offset(0.5, 0.85),
          ),
        ),
        text: PlacemarkText(
          text: shop.name,
          style: PlacemarkTextStyle(
            size: 11,
            color: isSelected ? AppColors.primary : const Color(0xFF333333),
            outlineColor: Colors.white,
            placement: TextStylePlacement.bottom,
            offset: 2,
            offsetFromIcon: true,
          ),
        ),
        onTap: (_, __) => _onMarkerTapped(index),
      );
    }).toList();
  }

  // ──────────────────────────── Interactions ────────────────────────────

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    _moveCameraTo(_tashkentCenter, zoom: _defaultZoom, animate: false);
  }

  Future<void> _moveCameraTo(
    Point target, {
    double zoom = _focusZoom,
    bool animate = true,
  }) async {
    await _mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
      animation: animate
          ? const MapAnimation(
              type: MapAnimationType.smooth,
              duration: 0.4,
            )
          : null,
    );
  }

  void _selectShop(int index) {
    if (index < 0 || index >= _filteredShops.length) return;
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    final shop = _filteredShops[index];
    _moveCameraTo(
      Point(latitude: shop.latitude!, longitude: shop.longitude!),
    );
  }

  void _onMarkerTapped(int index) {
    _selectShop(index);

    // Sync carousel to this shop
    if (_pageController.hasClients) {
      _isPageAnimating = true;
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) => _isPageAnimating = false);
    }
  }

  void _onPageChanged(int index) {
    // Only react to user swipes, not programmatic animations
    if (!_isPageAnimating) {
      _selectShop(index);
    }
  }

  void _openShopDetail(ShopModel shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopDetailScreen(shop: shop),
      ),
    );
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = List.from(_shops);
      } else {
        _filteredShops = _shops
            .where((s) =>
                s.name.toLowerCase().contains(query.toLowerCase()) ||
                s.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _selectedIndex = 0;
    });

    // Fit all filtered markers
    if (_filteredShops.isNotEmpty) {
      final first = _filteredShops.first;
      _moveCameraTo(
        Point(latitude: first.latitude!, longitude: first.longitude!),
        zoom: _filteredShops.length == 1 ? _focusZoom : _defaultZoom,
      );
    }

    // Reset carousel
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  // ──────────────────────────── Build ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            // ─── Yandex Map ───
            YandexMap(
              onMapCreated: _onMapCreated,
              mapObjects: _buildPlacemarks(),
              onMapTap: (_) {
                // Deselect only if user taps empty area
                // Keep selectedIndex for carousel consistency
              },
              logoAlignment: const MapAlignment(
                horizontal: HorizontalAlignment.right,
                vertical: VerticalAlignment.bottom,
              ),
            ),

            // ─── Top: Search bar ───
            Positioned(
              top: topPadding + 8,
              left: 16,
              right: 16,
              child: _SearchBar(
                controller: _searchController,
                onChanged: _onSearch,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),

            // ─── Bottom: Horizontal shop carousel ───
            Positioned(
              bottom: bottomPadding + 20,
              left: 0,
              right: 0,
              child: _filteredShops.isEmpty
                  ? _buildEmptyState()
                  : SizedBox(
                      height: 108,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _filteredShops.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final shop = _filteredShops[index];
                          final isSelected = index == _selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _ShopCarouselCard(
                              shop: shop,
                              isSelected: isSelected,
                              onTap: () => _openShopDetail(shop),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            // ─── Yandex Maps attribution ───
            Positioned(
              bottom: bottomPadding + 136,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 10, color: Colors.red[700]),
                    const SizedBox(width: 2),
                    Text(
                      'Yandex Maps',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 36, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(
              'Nonvoyxona topilmadi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  SEARCH BAR
// ════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          _CircleButton(
            icon: Icons.arrow_back,
            onTap: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Nonvoyxonani qidirish...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 32,
                  minHeight: 20,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 22, color: AppColors.divider),
          IconButton(
            icon: const Icon(Icons.tune, size: 22),
            color: AppColors.textSecondary,
            onPressed: () {
              // TODO: Filter bottom sheet
            },
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  HORIZONTAL SHOP CAROUSEL CARD
// ════════════════════════════════════════════════════════════════════

class _ShopCarouselCard extends StatelessWidget {
  final ShopModel shop;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShopCarouselCard({
    required this.shop,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Shop image
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0EB),
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Icon(
                  Icons.bakery_dining,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 12),
              // Shop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            shop.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Hours + Status
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${shop.openTime} - ${shop.closeTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(isOpen: shop.isOpen),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  STATUS BADGE
// ════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final bool isOpen;

  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withValues(alpha: 0.1)
            : const Color(0xFFE65100).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isOpen ? 'Ochiq' : 'Yopiq',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOpen ? AppColors.success : const Color(0xFFE65100),
        ),
      ),
    );
  }
}