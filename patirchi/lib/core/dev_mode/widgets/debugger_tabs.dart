import 'package:flutter/material.dart';

import 'package:patirchi/core/dev_mode/widgets/tabs/actions_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/api_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/device_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/logs_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/network_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/state_tab.dart';
import 'package:patirchi/core/dev_mode/widgets/tabs/storage_tab.dart';

/// Debugger tabledagi barcha tab widgetlari ro'yxati.
///
/// `debugger_sheet.dart` tomonidan ishlatiladi.
/// Tartib [debuggerTabLabels] bilan mos kelishi shart.
const List<Widget> debuggerTabs = [
  NetworkTab(),
  LogsTab(),
  StateTab(),
  StorageTab(),
  ApiTab(),
  DeviceTab(),
  ActionsTab(),
];

/// Tab sarlavhalari — [debuggerTabs] bilan bir xil tartibda.
const List<String> debuggerTabLabels = [
  'Network',
  'Logs',
  'State',
  'Storage',
  'API',
  'Device',
  'Actions',
];

/// Tab iconlari — [debuggerTabs] bilan bir xil tartibda.
const List<IconData> debuggerTabIcons = [
  Icons.wifi_rounded,
  Icons.receipt_long_outlined,
  Icons.device_hub_outlined,
  Icons.lock_outline,
  Icons.api_outlined,
  Icons.phone_android_outlined,
  Icons.flash_on_outlined,
];
