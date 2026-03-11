import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SidebarMenuItem {
  final IconData icon;
  final String title;
  final List<SidebarMenuItem>? children;
  final VoidCallback? onTap;

  const SidebarMenuItem({
    required this.icon,
    required this.title,
    this.children,
    this.onTap,
  });
}

class AppSidebar extends StatefulWidget {
  final String title;
  final Color gradientColor;
  final List<SidebarMenuItem> items;
  final String? avatarUrl;

  const AppSidebar({
    super.key,
    required this.title,
    required this.gradientColor,
    required this.items,
    this.avatarUrl,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final Set<int> _expandedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.gradientColor,
              widget.gradientColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Asosiy menyu',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final hasChildren =
                        item.children != null && item.children!.isNotEmpty;
                    final isExpanded = _expandedIndices.contains(index);

                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(item.icon, color: Colors.white, size: 22),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: hasChildren
                              ? Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                )
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusS),
                          ),
                          onTap: () {
                            if (hasChildren) {
                              setState(() {
                                if (isExpanded) {
                                  _expandedIndices.remove(index);
                                } else {
                                  _expandedIndices.add(index);
                                }
                              });
                            } else {
                              item.onTap?.call();
                              Navigator.pop(context);
                            }
                          },
                        ),
                        if (hasChildren && isExpanded)
                          ...item.children!.map(
                            (child) => Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: ListTile(
                                dense: true,
                                leading: Icon(child.icon,
                                    color: Colors.white70, size: 18),
                                title: Text(
                                  child.title,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  child.onTap?.call();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}