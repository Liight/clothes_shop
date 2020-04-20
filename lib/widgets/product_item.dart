// flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// custom
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // arguments
    final product = Provider.of<Product>(context,
        listen: false); // false to stop rebuilds when product changes
    final cart = Provider.of<Cart>(context,
        listen: false); // false to stop rebuilds when cart changes
        final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(
                product.isFavourite == true
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () {
                product.toggleFavouriteStatus(authData.token); // favourite / un-favourite
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              // Show snackbar on main screen when item is added to cart
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart',
                ),
                duration: Duration(seconds: 2),
                action: SnackBarAction(label: 'UNDO', onPressed: () => cart.removeSingleItem(product.id),),
              ));
            },
          ),
        ),
      ),
    );
  }
}
