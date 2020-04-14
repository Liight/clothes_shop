// dart
import 'dart:convert';
// flutter
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// custom
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   ),
  ];

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // FETCH PRODUCT
  Future<void> fetchAndSetProducts() async {
    const url = 'https://clothing-store-68547.firebaseio.com/products.json';
    try {
      final response = await http.get(url); // Get this first
      print(response.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      // Build products from server data
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavourite: prodData['isFavourite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts; // Store products in items list
      notifyListeners(); // Update app
      print(extractedData);
    } catch (error) {
      throw (error);
      // print(error);
    }
  }

  // ADD PRODUCT
  // Return a future that resolves to void, 'async' wraps functions in futures
  Future<void> addProduct(Product product) async {
    
    const url = 'https://clothing-store-68547.firebaseio.com/products.json'; // Server (firebase)
    // Start Error Handler
    try {
      // Invisible Future stored as variable
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
        }),
      );

      // Local (invisible 'then' block) because of 'await'
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'], // Get Id From Server
      );
      // Update Local items List
      _items.add(newProduct);
      // Update Widget Tree
      notifyListeners();
      // Handle Errors
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://clothing-store-68547.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            // 'isFavourite': newProduct.isFavourite, // Do not want to reset is Favourite status on server
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      // ...
    }
    notifyListeners();
  }

  // Optimistic Updating: This ensures the product is re-added if the delete fails
  void deleteProduct(String id) {
    final url = 'https://clothing-store-68547.firebaseio.com/products/$id';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    // Delete will not throw an error when recieves error from server
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {}
      existingProduct = null;
    }).catchError((_) {
      _items.insert(existingProductIndex,
          existingProduct); // Re-insert item if delete failed (rollback)
      notifyListeners();
    });
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
