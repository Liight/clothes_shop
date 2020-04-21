// flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Screens
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
// Providers
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

// run app
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // ChangeNotifierProxyProvider creates a Provider with a dependancy on another previously declared Provider
          create: (ctx) => Products(
            Provider.of<Auth>(ctx, listen: false).token,
            Provider.of<Auth>(ctx, listen: false).userId,
            [],
          ),
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          // ChangeNotifierProxyProvider creates a Provider with a dependancy on another previously declared Provider
          create: (ctx) => Orders(
            Provider.of<Auth>(ctx, listen: false).token,
            [],
            Provider.of<Auth>(ctx, listen: false).userId,
          ),
          update: (ctx, auth, previousOrders) => Orders(auth.token,
              previousOrders == null ? [] : previousOrders.orders, auth.userId),
        ),
      ],
      child: Consumer<Auth>(
        // Wrapping MaterialApp with Consumer ensures the MaterialApp rebuilds
        // when the Auth object changes, and whenever notifyListeners is called in the Auth object.
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          // Are we authenticated?
          // if yes autolog, while wait show splash screen
          // if not show auth screen
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
          },
        ),
      ),
    );
  }
}
