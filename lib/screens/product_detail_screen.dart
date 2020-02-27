// flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// custom
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(context, listen: false).findById(
        productId); // Will not update when notify listeners is called as is not set as an active listener

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loadedProduct.title,
        ),
      ),
      body: Container(),
    );
  }
}
