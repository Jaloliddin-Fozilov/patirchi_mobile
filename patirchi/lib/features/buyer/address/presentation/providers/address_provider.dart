import 'package:flutter/material.dart';
import 'package:patirchi/features/buyer/address/data/models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final List<AddressModel> _addresses = [
    const AddressModel(
      id: 'addr_1',
      label: 'Uy',
      street: 'Chilonzor ko\'chasi',
      building: '12',
      apartment: '45',
      floor: '4',
      entrance: '2',
      isDefault: true,
      latitude: 41.2995,
      longitude: 69.2401,
    ),
    const AddressModel(
      id: 'addr_2',
      label: 'Ish',
      street: 'Yunusobod ko\'chasi',
      building: '7',
      apartment: '301',
      floor: '3',
      entrance: '1',
      isDefault: false,
      latitude: 41.3600,
      longitude: 69.3200,
    ),
  ];

  AddressModel? _selectedAddress;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);

  AddressModel? get selectedAddress =>
      _selectedAddress ??
      (_addresses.isNotEmpty
          ? _addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => _addresses.first,
            )
          : null);

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress(AddressModel address) {
    final newAddress = address.copyWith(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
    );
    if (_addresses.isEmpty || address.isDefault) {
      final updated = _addresses
          .map((a) => a.copyWith(isDefault: false))
          .toList();
      _addresses.clear();
      _addresses.addAll(updated);
      _addresses.add(newAddress.copyWith(isDefault: true));
    } else {
      _addresses.add(newAddress);
    }
    notifyListeners();
  }

  void updateAddress(AddressModel address) {
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) {
      _addresses[idx] = address;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = null;
    }
    notifyListeners();
  }

  void setDefault(String id) {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
    notifyListeners();
  }
}
