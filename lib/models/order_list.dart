import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';
import 'package:http/http.dart' as http;

class OrderList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Order> _items = [];

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;

  OrderList([
    this._token = '',
    this._userId = '',
    this._items = const [],
  ]);

  Future<void> loadOrders() async {
    List<Order> items = [];

    final response = await http.get(
      Uri.parse('${Constants.ORDERS_BASE_URL}/$_userId.json?auth=$_token'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      items.add(
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
    _items = items.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse('${Constants.ORDERS_BASE_URL}/$_userId.json?auth=$_token'),
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
