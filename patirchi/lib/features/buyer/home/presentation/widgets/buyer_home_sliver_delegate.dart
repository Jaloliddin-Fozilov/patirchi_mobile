import 'package:flutter/material.dart';

class BuyerHomeSliverDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;
  final Widget searchBar;
  final Widget middleRow;
  final Widget promoBanner;

  BuyerHomeSliverDelegate({
    required this.statusBarHeight,
    required this.searchBar,
    required this.middleRow,
    required this.promoBanner,
  });

  static const _locationH = 48.0;
  static const _searchH = 64.0;
  static const _bannerH = 150.0;

  @override
  double get maxExtent =>
      statusBarHeight + _locationH + _searchH + _bannerH;

  @override
  double get minExtent => statusBarHeight + _searchH;

  @override
  bool shouldRebuild(covariant BuyerHomeSliverDelegate oldDelegate) => true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final expandable = maxExtent - minExtent;
    final double t = (1.0 - shrinkOffset / expandable).clamp(0.0, 1.0);
    final radius = 24.0 * t;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                  const Color(0xFF2A2A2A), const Color(0xFFE91E90), t)!,
              Color.lerp(
                  const Color(0xFF2A2A2A), const Color(0xFFFF4D8D), t)!,
              Color.lerp(
                  const Color(0xFF2A2A2A), const Color(0xFFFF6B9D), t)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: statusBarHeight),
            ClipRect(
              child: SizedBox(
                height: _locationH * t,
                child: Opacity(
                  opacity: t,
                  child: SizedBox(height: _locationH, child: middleRow),
                ),
              ),
            ),
            SizedBox(
              height: _searchH,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: searchBar,
              ),
            ),
            ClipRect(
              child: SizedBox(
                height: _bannerH * t,
                child: Opacity(
                  opacity: t,
                  child: SizedBox(
                    height: _bannerH,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: promoBanner,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
