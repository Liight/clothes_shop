import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = './edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
// Set focus nodes for form routing behaviour
final _priceFocusNode = FocusNode(); // 
final _descriptionFocusNode = FocusNode();
// Handle garbage collection for focus nodes
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next, // Icon
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode); // Refocus request 1
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode, // Focus 1 address
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode); // Refocus request 1
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                textInputAction: TextInputAction.next, // Icon
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode, // Focus 1 address
              ),
            ],
          ),
        ),
      ),
    );
  }
}
