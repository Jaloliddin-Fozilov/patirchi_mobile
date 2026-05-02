import 'package:flutter/foundation.dart';
import 'package:patirchi/core/constants/enums.dart';
import 'package:patirchi/core/error/result.dart';
import 'package:patirchi/features/supplier/data/repositories/supplier_repository.dart';
import 'package:patirchi/features/supplier/orders/data/models/supplier_order_model.dart';

class SupplierOrdersProvider extends ChangeNotifier {
  SupplierOrdersProvider({SupplierRepository? repository})
      : _repo = repository ?? SupplierRepository();

  final SupplierRepository _repo;

  // State
  bool _isLoading = false;
  String? _error;
  List<SupplierOrderModel> _orders = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // Init — API dan yuklash
  // ---------------------------------------------------------------------------

  /// Barcha buyurtmalarni API dan yuklaydi.
  ///
  /// Agar API xato qaytarsa, mock data bilan davom etiladi.
  Future<void> loadOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repo.getSupplierOrders(status: status);
    result.fold(
      onSuccess: (orders) => _orders = orders,
      onError: (failure) {
        _error = failure.toUserMessage();
        _orders = _mockOrders;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<SupplierOrderModel> get allOrders => List.unmodifiable(_orders);

  List<SupplierOrderModel> ordersByStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  List<SupplierOrderModel> get pendingOrders =>
      ordersByStatus(OrderStatus.pending);

  int get todayOrderCount {
    final today = DateTime.now();
    return _orders
        .where(
          (o) =>
              o.createdAt.year == today.year &&
              o.createdAt.month == today.month &&
              o.createdAt.day == today.day,
        )
        .length;
  }

  int get totalRevenue => _orders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0, (sum, o) => sum + o.total);

  // ---------------------------------------------------------------------------
  // Status o'zgartirish (lokal — backend endpoint yo'q)
  // ---------------------------------------------------------------------------

  // TODO(backend): Backend supplier order status update endpointini qo'shgach,
  // bu metodni API chaqiruvlari bilan almashtirish kerak.

  void updateStatus(String id, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Mock fallback data
  // ---------------------------------------------------------------------------

  static final List<SupplierOrderModel> _mockOrders = [
    SupplierOrderModel(
      id: 'so1',
      orderNumber: 'SUP-001',
      bakeryName: 'Toshkent Non zavodi',
      bakeryAddress: 'Yunusobod 14, Toshkent',
      bakeryPhone: '901234567',
      items: const [
        SupplierOrderItem(
          productId: 'p1',
          productName: 'Oliy nav un',
          unit: 'kg',
          quantity: 200,
          unitPrice: 12000,
        ),
        SupplierOrderItem(
          productId: 'p5',
          productName: 'Oq shakar',
          unit: 'kg',
          quantity: 50,
          unitPrice: 14000,
        ),
      ],
      status: OrderStatus.pending,
      createdAt: DateTime(2026, 4, 16, 9, 30),
    ),
    SupplierOrderModel(
      id: 'so2',
      orderNumber: 'SUP-002',
      bakeryName: 'Samarqand Non',
      bakeryAddress: "Mirzo Ulug'bek 5, Toshkent",
      bakeryPhone: '909876543',
      items: const [
        SupplierOrderItem(
          productId: 'p2',
          productName: '1-nav un',
          unit: 'kg',
          quantity: 500,
          unitPrice: 9500,
        ),
      ],
      status: OrderStatus.confirmed,
      createdAt: DateTime(2026, 4, 15, 14, 20),
    ),
    SupplierOrderModel(
      id: 'so3',
      orderNumber: 'SUP-003',
      bakeryName: "Do'stlik Nonvoyxona",
      bakeryAddress: 'Chilonzor 22, Toshkent',
      bakeryPhone: '905551122',
      items: const [
        SupplierOrderItem(
          productId: 'p3',
          productName: "G'o'za yog'i",
          unit: 'litr',
          quantity: 30,
          unitPrice: 18000,
        ),
        SupplierOrderItem(
          productId: 'p6',
          productName: 'Tuxum (qishloq)',
          unit: 'dona',
          quantity: 120,
          unitPrice: 1800,
        ),
      ],
      status: OrderStatus.preparing,
      createdAt: DateTime(2026, 4, 15, 10, 5),
    ),
    SupplierOrderModel(
      id: 'so4',
      orderNumber: 'SUP-004',
      bakeryName: 'Arzon Non',
      bakeryAddress: 'Sergeli 7, Toshkent',
      bakeryPhone: '997001234',
      items: const [
        SupplierOrderItem(
          productId: 'p1',
          productName: 'Oliy nav un',
          unit: 'kg',
          quantity: 100,
          unitPrice: 12000,
        ),
      ],
      status: OrderStatus.delivering,
      createdAt: DateTime(2026, 4, 14, 16, 0),
    ),
    SupplierOrderModel(
      id: 'so5',
      orderNumber: 'SUP-005',
      bakeryName: "G'oliblar Non",
      bakeryAddress: 'Shayxontohur 3, Toshkent',
      bakeryPhone: '901111222',
      items: const [
        SupplierOrderItem(
          productId: 'p4',
          productName: "Kungaboqar yog'i",
          unit: 'litr',
          quantity: 20,
          unitPrice: 16500,
        ),
        SupplierOrderItem(
          productId: 'p8',
          productName: 'Osh tuzi',
          unit: 'kg',
          quantity: 50,
          unitPrice: 2500,
        ),
      ],
      status: OrderStatus.delivered,
      createdAt: DateTime(2026, 4, 13, 11, 45),
    ),
    SupplierOrderModel(
      id: 'so6',
      orderNumber: 'SUP-006',
      bakeryName: 'Vatanparvar Non',
      bakeryAddress: 'Bektemir 12, Toshkent',
      bakeryPhone: '902223344',
      items: const [
        SupplierOrderItem(
          productId: 'p7',
          productName: 'Sigir suti',
          unit: 'litr',
          quantity: 50,
          unitPrice: 8000,
        ),
      ],
      status: OrderStatus.cancelled,
      createdAt: DateTime(2026, 4, 12, 8, 0),
    ),
  ];
}
