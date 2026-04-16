import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:patirchi/core/theme/app_colors.dart';
import '../../data/datasources/buyer_home_local_datasource.dart';
import '../../data/models/shop_model.dart';
import 'shop_detail_screen.dart';
import '../widgets/map_widgets.dart';

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

  void _showFilterSheet(BuildContext context) {
    bool onlyOpen = false;
    final List<String> districts = [
      'Chilonzor',
      'Yunusobod',
      'Shayhontohur',
      'Mirzo Ulug\'bek',
      'Olmazor',
      'Yakkasaroy',
    ];
    final Set<String> selectedDistricts = {};
    double minRating = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 8,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Filtr',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Only open toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Faqat ochiq do\'konlar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch.adaptive(
                        value: onlyOpen,
                        onChanged: (v) => setSheetState(() => onlyOpen = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // District checkboxes
                  const Text(
                    'Tuman bo\'yicha',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: districts.map((d) {
                      final selected = selectedDistricts.contains(d);
                      return FilterChip(
                        label: Text(d),
                        selected: selected,
                        onSelected: (v) {
                          setSheetState(() {
                            if (v) {
                              selectedDistricts.add(d);
                            } else {
                              selectedDistricts.remove(d);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected ? AppColors.primary : Colors.grey[300]!,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Rating slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reyting bo\'yicha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            minRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            ' va yuqori',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Slider(
                    value: minRating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                    onChanged: (v) => setSheetState(() => minRating = v),
                  ),
                  const SizedBox(height: 16),
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Qo\'llash',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
              child: MapSearchBar(
                controller: _searchController,
                onChanged: _onSearch,
                onBack: () => Navigator.of(context).pop(),
                onFilter: () => _showFilterSheet(context),
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
                            child: ShopCarouselCard(
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

// Widget'lar map_widgets.dart ga ko'chirilgan