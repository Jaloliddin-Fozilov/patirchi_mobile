import 'package:flutter/widgets.dart';

/// Global navigator kalit — `MaterialApp.navigatorKey` ga biriktiriladi.
///
/// Sabab: `MaterialApp.builder` callback ABOVE the inner Navigator deb
/// chaqiriladi, shu sababli builder ichidagi context'da
/// [Navigator.of] qaytaradigan ancestor yo'q. `showModalBottomSheet`
/// kabi API'lar `Navigator.of(context)!` ishlatadi va release rejimda
/// "Null check operator used on a null value" tashlaydi.
///
/// Yechim: barcha global UI (dev FAB, debugger sheet, snackbar va h.k.)
/// shu kalit orqali Navigator state'iga murojaat qiladi.
final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'appNavigatorKey');
