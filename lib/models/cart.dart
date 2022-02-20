import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;

    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });

    return total;
  }

  void add(Product product) {
    if (items.containsKey(product.id)) {
      _items.update(
          product.id,
          (value) => CartItem(
                id: value.id,
                name: value.name,
                price: value.price,
                productId: value.id,
                quantity: value.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: Random().nextDouble().toString(),
          name: product.name,
          price: product.price,
          productId: product.id,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]?.quantity == 1) {
      _items.remove(productId);
    } else {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          name: value.name,
          price: value.price,
          productId: value.id,
          quantity: value.quantity - 1,
        ),
      );
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
