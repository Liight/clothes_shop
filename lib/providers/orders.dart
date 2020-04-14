import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url =
        'https://clothing-store-68547.firebaseio.com/orders.json'; // Server (firebase)
    final timestamp = DateTime.now(); // Store current date and time
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp
            .toIso8601String(), // String that is recreatable as a datetime (usefull for storing dates as string in databases)
        'products': cartProducts
            .map((cProd) => {
                  'id': cProd.id,
                  'title': cProd.title,
                  'quantity': cProd.quantity,
                  'price': cProd.price,
                })
            .toList(),
      }),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
