import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerDashboard extends StatefulWidget {
  final FirebaseAuth auth;

  SellerDashboard({Key? key, required this.auth}) : super(key: key);

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController =
      TextEditingController();
  final TextEditingController _productImageController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  Future<void> _addProduct() async {
    String productName = _productNameController.text;
    String productDescription = _productDescriptionController.text;
    String productImage = _productImageController.text;
    double productPrice = double.parse(_productPriceController.text);

    if (productName.isNotEmpty &&
        productDescription.isNotEmpty &&
        productImage.isNotEmpty &&
        productPrice > 0) {
      // Create a new product document
      await _products.doc(productName).set({
        'product-name': productName,
        'product-description': productDescription,
        'product-img': productImage,
        'product-price': productPrice,
        'product-rating': 0,
        'seller-id': widget.auth.currentUser?.uid, // Add seller ID
      });

      // Clear input fields
      _productNameController.clear();
      _productDescriptionController.clear();
      _productImageController.clear();
      _productPriceController.clear();
    } else {
      // Handle invalid input
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill in all fields with valid data.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToManageProducts() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Manage Products'),
          content: Text('You can manage your products here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _productDescriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
            ),
            TextField(
              controller: _productImageController,
              decoration: InputDecoration(labelText: 'Product Image URL'),
            ),
            TextField(
              controller: _productPriceController,
              decoration: InputDecoration(labelText: 'Product Price'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addProduct();
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 20),
            Text(
              'Manage Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to a screen for managing products
                _navigateToManageProducts();
              },
              child: Text('View Products'),
            ),
          ],
        ),
      ),
    );
  }
}
