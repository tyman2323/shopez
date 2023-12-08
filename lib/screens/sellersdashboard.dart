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
    // ... (unchanged)

    // Clear input fields
    _productNameController.clear();
    _productDescriptionController.clear();
    _productImageController.clear();
    _productPriceController.clear();
  }

  void myproducts() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: _products
            .where('seller-id', isEqualTo: widget.auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Text('No products added yet.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(product['product-name']),
                subtitle: Text('Price: \$${product['product-price']}'),
                // You can add more details or actions here
              );
            },
          );
        },
      ),
    ));
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
            // ... (unchanged)
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
                myproducts();
              },
              child: Text('View Products'),
            ),
          ],
        ),
      ),
    );
  }
}
