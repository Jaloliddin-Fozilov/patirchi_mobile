import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/dev_mode/api_observer.dart';
import 'package:patirchi/core/dev_mode/app_logger.dart';
import 'package:patirchi/core/dev_mode/app_navigator_key.dart';
import 'package:patirchi/core/dev_mode/dev_mode_service.dart';
import 'package:patirchi/core/dev_mode/provider_registry.dart';
import 'package:patirchi/core/dev_mode/stores/log_store.dart';
import 'package:patirchi/core/dev_mode/stores/network_log_store.dart';
import 'package:patirchi/core/dev_mode/widgets/dev_mode_overlay.dart';
import 'package:patirchi/core/theme/app_theme.dart';
import 'package:patirchi/core/theme/theme_provider.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';
import 'package:patirchi/features/auth/presentation/screens/splash_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/login_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/register_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/otp_screen.dart';
import 'package:patirchi/features/buyer/buyer_shell.dart';
import 'package:patirchi/features/buyer/home/presentation/providers/buyer_home_provider.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';
import 'package:patirchi/features/buyer/checkout/presentation/providers/checkout_provider.dart';
import 'package:patirchi/features/buyer/orders/presentation/providers/orders_provider.dart';
import 'package:patirchi/features/buyer/address/presentation/providers/address_provider.dart';
import 'package:patirchi/features/notification/presentation/providers/notification_provider.dart';
import 'package:patirchi/features/buyer/checkout/presentation/screens/checkout_screen.dart';
import 'package:patirchi/features/buyer/orders/presentation/screens/buyer_orders_screen.dart';
import 'package:patirchi/features/buyer/address/presentation/screens/address_list_screen.dart';
import 'package:patirchi/features/notification/presentation/screens/notification_screen.dart';
import 'package:patirchi/features/bakery/bakery_shell.dart';
import 'package:patirchi/features/bakery/orders/presentation/providers/bakery_orders_provider.dart';
import 'package:patirchi/features/bakery/menu/presentation/providers/menu_provider.dart';
import 'package:patirchi/features/bakery/inventory/presentation/providers/inventory_provider.dart';
import 'package:patirchi/features/bakery/finance/presentation/providers/finance_provider.dart';
import 'package:patirchi/features/chat/presentation/providers/chat_provider.dart';
import 'package:patirchi/features/supplier/supplier_shell.dart';
import 'package:patirchi/features/supplier/products/presentation/providers/supplier_products_provider.dart';
import 'package:patirchi/features/supplier/orders/presentation/providers/supplier_orders_provider.dart';
import 'package:patirchi/features/supplier/stats/presentation/providers/supplier_stats_provider.dart';
import 'package:patirchi/features/courier/courier_shell.dart';
import 'package:patirchi/features/courier/deliveries/presentation/providers/courier_provider.dart';
import 'package:patirchi/features/courier/wallet/presentation/providers/wallet_provider.dart';

// ---------------------------------------------------------------------------
// Global dev mode singletons
// ---------------------------------------------------------------------------

final kNetworkLogStore = NetworkLogStore.instance;
final kLogStore = LogStore.instance;

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Developer mode holatini yuklash
  await DevModeService.instance.init();

  // Network observer o'rnatish
  ApiObserverRegistry.observer = RecordingApiObserver(kNetworkLogStore);

  // debugPrint ni ushlab olish
  AppLogger.install(kLogStore);

  runApp(const PatirchiApp());
}

class PatirchiApp extends StatelessWidget {
  const PatirchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dev mode singletons — Provider sifatida ro'yxatdan o'tkazish
        ChangeNotifierProvider<NetworkLogStore>.value(value: kNetworkLogStore),
        ChangeNotifierProvider<LogStore>.value(value: kLogStore),
        ChangeNotifierProvider<DevModeService>.value(
          value: DevModeService.instance,
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BuyerHomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BakeryOrdersProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProductsProvider()),
        ChangeNotifierProvider(create: (_) => SupplierOrdersProvider()),
        ChangeNotifierProvider(create: (_) => SupplierStatsProvider()),
        ChangeNotifierProvider(create: (_) => CourierProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Provider snapshot'larini bir marta ro'yxatdan o'tkazish
          _registerProviderSnapshots(context);
          return MaterialApp(
            title: 'Patirchi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: _onGenerateRoute,
            // Global navigator kalit — dev FAB modal'larini chaqirish uchun.
            navigatorKey: appNavigatorKey,
            // Developer mode FAB overlay — barcha screen ustida
            builder: DevModeOverlay.wrap,
          );
        },
      ),
    );
  }

  /// Dev panel State tab uchun provider snapshot'larini ro'yxatdan o'tkazadi.
  ///
  /// [Consumer.builder] ichida chaqiriladi, shu sababli context tayyor.
  void _registerProviderSnapshots(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final theme = context.read<ThemeProvider>();

    ProviderRegistry.register(
      'AuthProvider',
      () => {
        'isLoggedIn': auth.isLoggedIn,
        'isLoading': auth.isLoading,
        'role': auth.currentUserRole.name,
        'selectedRole': auth.selectedRole,
        'error': auth.errorMessage,
      },
    );

    ProviderRegistry.register(
      'CartProvider',
      () => {
        'itemCount': cart.itemCount,
        'subtotal': cart.subtotal,
        'total': cart.total,
        'deliveryFee': cart.deliveryFee,
        'deliveryMethod': cart.deliveryMethod.name,
        'isLoading': cart.isLoading,
      },
    );

    ProviderRegistry.register(
      'ThemeProvider',
      () => {
        'themeMode': theme.themeMode.name,
      },
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/role-selection':
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/otp':
        final phone = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpScreen(phoneNumber: phone),
        );
      case '/home':
        return MaterialPageRoute(builder: (_) => const _HomeRouter());
      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const BuyerOrdersScreen());
      case '/addresses':
        return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}

class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentUserRole;
    return switch (role) {
      UserRole.buyer => const BuyerShell(),
      UserRole.bakery => const BakeryShell(),
      UserRole.supplier => const SupplierShell(),
      UserRole.courier => const CourierShell(),
    };
  }
}
