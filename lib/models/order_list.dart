import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';
import 'package:http/http.dart' as http;

class OrderList with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;
  Future<void> loadOrders() async {
    _items.clear();

    final response = await http.get(
      Uri.parse('${Constants.ORDERS_BASE_URL}.json'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      _items.add(
        Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: orderData['total'],
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['name'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList(),
        ),
      );
    });
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('${Constants.ORDERS_BASE_URL}.json'),
      body: jsonEncode(
        {
          "date": date.toIso8601String(),
          "total": cart.totalAmount,
          "products": cart.items.values
              .map(
                (cartItem) => {
                  "id": cartItem.id,
                  "name": cartItem.name,
                  "price": cartItem.price,
                  "quantity": cartItem.quantity,
                  "productId": cartItem.productId,
                },
              )
              .toList(),
        },
      ),
    );
    final id = jsonDecode(response.body)["name"];

    _items.insert(
      0,
      Order(
        id: id,
        date: date,
        products: cart.items.values.toList(),
        total: cart.totalAmount,
      ),
    );

    notifyListeners();
  }
}
