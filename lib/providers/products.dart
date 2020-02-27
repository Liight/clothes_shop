import 'package:flutter/material.dart';

import '../models/product.dart';

class Product with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  void addProduct(Product newProduct){
    // _items.add(newProduct);
    notifyListeners();
  }
}