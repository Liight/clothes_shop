// flutter
import 'package:flutter/material.dart';
// custom
import '../widgets/products_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  

  ProductsOverviewScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
      ),
      body: ProductsGrid(),
    );
  }
}

