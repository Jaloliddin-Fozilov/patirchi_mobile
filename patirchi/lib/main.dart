import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/theme/app_theme.dart';
import 'package:patirchi/core/theme/theme_provider.dart';
import 'package:patirchi/features/auth/presentation/providers/auth_provider.dart';
import 'package:patirchi/features/auth/presentation/screens/splash_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/login_screen.dart';
import 'package:patirchi/features/auth/presentation/screens/register_screen.dart';
import 'package:patirchi/features/buyer/buyer_shell.dart';
import 'package:patirchi/features/buyer/home/presentation/providers/buyer_home_provider.dart';
import 'package:patirchi/features/buyer/cart/presentation/providers/cart_provider.dart';
import 'package:patirchi/features/bakery/bakery_shell.dart';
import 'package:patirchi/features/supplier/supplier_shell.dart';
import 'package:patirchi/features/courier/courier_shell.dart';

void main() {
  runApp(const PatirchiApp());
}

class PatirchiApp extends StatelessWidget {
  const PatirchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BuyerHomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Patirchi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
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
      case '/home':
        return MaterialPageRoute(builder: (_) => const _HomeRouter());
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
    final role = context.watch<AuthProvider>().selectedRole;
    switch (role) {
      case UserRole.buyer:
        return const BuyerShell();
      case UserRole.bakery:
        return const BakeryShell();
      case UserRole.supplier:
        return const SupplierShell();
      case UserRole.courier:
        return const CourierShell();
    }
  }
}
