// flutter
import 'package:flutter/foundation.dart'; // @required fields in class constructor
import 'package:http/http.dart' as http; // http network requests
import 'dart:convert'; // json conversions

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  // Helper Method for Changing the Users isFavourite Value on a Selected Item
  void _setFavValue(bool newValue) {
    isFavourite = newValue; // set favourite value to the newValue provided
    notifyListeners(); // update app state and trigger renders
  }

  // Update the users isFavourite status on a selected item
  // Optimistic Updating with a Future
  Future<void> toggleFavouriteStatus(String token) async {
    final oldStatus = isFavourite; // store data before change
    isFavourite = !isFavourite; // transform data
    notifyListeners(); // update app state and trigger renders
    final url =
        'https://clothing-store-68547.firebaseio.com/products/$id.json?auth=$token'; // id required
    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavourite': isFavourite, // store transformed data
        }),
      );
      if (response.statusCode >= 400) {
        _setFavValue(
            oldStatus); // rollback local changes if an eror occurs when updating the server
        print('Error: $response.statusCode');
      }
    } catch (error) {
      _setFavValue(
          oldStatus); // rollback local changes if an eror occurs when updating the server
      print(error);
    }
  }
}
