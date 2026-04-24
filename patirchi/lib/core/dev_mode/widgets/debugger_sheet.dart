import 'package:flutter/material.dart';
import 'package:patirchi/core/dev_mode/dev_mode_service.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/actions_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/api_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/device_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/logs_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/network_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/state_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/storage_tab.dart';

/// Developer debugger bottom sheet — 7 ta tab.
///
/// Tab kontentlari keyingi fazada to'ldiriladi.
class DebuggerSheet extends StatelessWidget {
  const DebuggerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: DevTheme.bgPrimary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DevTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                _DebuggerHeader(),
                // TabBar
                Container(
                  color: DevTheme.bgSecondary,
                  child: const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: DevTheme.accent,
                    unselectedLabelColor: DevTheme.textSecondary,
                    indicatorColor: DevTheme.accent,
                    dividerColor: DevTheme.borderSubtle,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.cloud_outlined, size: 18),
                        text: 'Network',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.article_outlined, size: 18),
                        text: 'Logs',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.data_object, size: 18),
                        text: 'State',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.storage_outlined, size: 18),
                        text: 'Storage',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.api_outlined, size: 18),
                        text: 'API',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.phone_android, size: 18),
                        text: 'Device',
                        height: 56,
                      ),
                      Tab(
                        icon: Icon(Icons.play_circle_outline, size: 18),
                        text: 'Actions',
                        height: 56,
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      NetworkTab(),
                      LogsTab(),
                      StateTab(),
                      StorageTab(),
                      ApiTab(),
                      DeviceTab(),
                      ActionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _DebuggerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: DevTheme.bgSecondary,
        border: Border(
          bottom: BorderSide(color: DevTheme.borderSubtle, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bug_report,
            color: DevTheme.accent,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Patirchi Debugger',
            style: DevTheme.title,
          ),
          const Spacer(),
          // Developer mode'ni o'chirish
          TextButton(
            onPressed: () async {
              await DevModeService.instance.disable();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Developer mode o\'chirildi'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: DevTheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              "O'chirish",
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 4),
          // Yopish
          IconButton(
            icon: const Icon(
              Icons.close,
              color: DevTheme.textSecondary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

