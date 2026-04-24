import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:patirchi/core/constants/app_constants.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_theme.dart';
import 'package:patirchi/core/dev_mode/widgets/shared/section_card.dart';

/// Qurilma ma'lumotlarini ko'rsatuvchi tab.
///
/// Platform, ekran o'lchami, app versiyasi va boshqalar.
class DeviceTab extends StatelessWidget {
  const DeviceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildDeviceSection(mq),
          const SizedBox(height: 12),
          _buildDisplaySection(context, mq),
          const SizedBox(height: 12),
          _buildAppSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(MediaQueryData mq) {
    return SectionCard(
      title: 'QURILMA',
      child: Column(
        children: [
          _DeviceRow(
            label: 'Platform',
            value: Platform.operatingSystem,
          ),
          _DeviceRow(
            label: 'OS versiyasi',
            value: Platform.operatingSystemVersion,
          ),
          _DeviceRow(
            label: 'Dart versiyasi',
            value: Platform.version.split(' ').first,
          ),
          _DeviceRow(
            label: 'Tili',
            value: WidgetsBinding.instance.platformDispatcher.locale.toString(),
          ),
          _DeviceRow(
            label: 'Yorqinlik',
            value: mq.platformBrightness == Brightness.dark ? 'Qorong\'i' : 'Yorug\'',
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySection(BuildContext context, MediaQueryData mq) {
    final size = mq.size;
    final padding = mq.padding;
    final textScaler = mq.textScaler;

    return SectionCard(
      title: 'EKRAN',
      child: Column(
        children: [
          _DeviceRow(
            label: 'O\'lchami',
            value: '${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)} dp',
          ),
          _DeviceRow(
            label: 'Pixel ratio',
            value: mq.devicePixelRatio.toStringAsFixed(2),
          ),
          _DeviceRow(
            label: 'Jismoniy piksel',
            value: '${(size.width * mq.devicePixelRatio).toStringAsFixed(0)} × '
                '${(size.height * mq.devicePixelRatio).toStringAsFixed(0)} px',
          ),
          _DeviceRow(
            label: 'Safe area top',
            value: '${padding.top.toStringAsFixed(0)}dp',
          ),
          _DeviceRow(
            label: 'Safe area bottom',
            value: '${padding.bottom.toStringAsFixed(0)}dp',
          ),
          _DeviceRow(
            label: 'Safe area left',
            value: '${padding.left.toStringAsFixed(0)}dp',
          ),
          _DeviceRow(
            label: 'Safe area right',
            value: '${padding.right.toStringAsFixed(0)}dp',
          ),
          _DeviceRow(
            label: 'Matn masshtabi',
            value: textScaler.scale(1.0).toStringAsFixed(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection() {
    return SectionCard(
      title: 'ILOVA',
      child: Column(
        children: [
          _DeviceRow(
            label: 'Nomi',
            value: AppConstants.appName,
          ),
          _DeviceRow(
            label: 'Versiyasi',
            value: AppConstants.appVersion,
          ),
          _DeviceRow(
            label: 'Base URL',
            value: AppConstants.baseUrl,
            mono: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device row
// ---------------------------------------------------------------------------

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: DevTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? DevTheme.mono.copyWith(
                      fontSize: 11,
                      color: DevTheme.textSecondary,
                    )
                  : const TextStyle(
                      color: DevTheme.textPrimary,
                      fontSize: 12,
                    ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nusxalandi'),
                  duration: Duration(seconds: 1),
                  backgroundColor: DevTheme.bgCard,
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.copy,
                size: 12,
                color: DevTheme.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
