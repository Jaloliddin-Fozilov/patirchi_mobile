import 'package:patirchi/features/buyer/home/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({required this.product, this.quantity = 1});

  int get totalPrice => product.price * quantity;
}
