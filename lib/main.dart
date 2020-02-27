// flutter
import 'package:flutter/material.dart';
// custom
import './screens/products_overview_screen.dart';
// run app
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyShop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductsOverviewScreen(),
    );
  }
}

