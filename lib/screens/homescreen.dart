import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/productscreen.dart';
import 'package:projecttwo/screens/sellersdashboard.dart';
import 'package:projecttwo/screens/settings.dart';
import 'package:projecttwo/screens/shoppingcart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.auth, required this.userDocSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// text fields' controllers

  final TextEditingController searchTextController = TextEditingController();

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference _userss =
      FirebaseFirestore.instance.collection('users');

  Future<void> _increaseProduct(String productId) async {
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentReference docRef = currentCart.doc('products_$productId');
    if (docRef != null) {
      await docRef.update({'count': FieldValue.increment(1)});
      //await currentCart.add({'count' : 1, 'price' : productSnap['price']});
    } else {
      await currentCart.doc('products_$productId').set({'count': 1});
    }
  }

  Future<void> _decreaseProduct(String productId) async {
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentReference docRef = currentCart.doc('products_$productId');
    if (docRef != null) {
      DocumentSnapshot docSnap = await docRef.get();
      if (docSnap['count'] == 1) {
        await currentCart.doc(docSnap.id).delete();
      }
    }
    await docRef.update({'count': FieldValue.increment(-1)});
  }

  Future<void> _addProductToCart(DocumentSnapshot productSnap) async {
    String productId = productSnap.id;
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentSnapshot temp = await currentCart.doc('products_$productId').get();
    if (temp.exists) {
      currentCart.doc('products_$productId').delete();
    } else {
      currentCart.doc('products_$productId').set({
        "count": 1,
        'name': productSnap['product-name'],
        'price': productSnap['product-price']
      }).onError((e, _) => print("Error writing document: $e"));
      ;
    }
  }

  //Future<void> addToCart
  Widget productList = Container(
    child: const Text('No matching products'),
  );
  void rebuildProductList(String str) {
    setState(() {
      productList = buildProductList(str);
    });
  }

  @override
  Widget build(BuildContext context) {
    productList = buildProductList(searchTextController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop EZ'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ShoppingCartScreen(
                      auth: widget.auth,
                      userDocSnap: widget.userDocSnap), //change to docref
                ),
              );
            },
            child: const Icon(Icons.shopping_cart),
          ),
          ElevatedButton(
            onPressed: () {
              //_signOut(); add to settings page instead
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => SettingsScreen(
                      auth: widget.auth, userDocSnap: widget.userDocSnap),
                ),
              );
            },
            child: const Icon(Icons.settings),
          ),
          ElevatedButton(
            onPressed: () {
              //_signOut(); add to settings page instead
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SellerDashboard(auth: widget.auth),
                ),
              );
            },
            child: const Icon(Icons.money),
          )
        ],
      ),
      backgroundColor: Colors.black12,
// Using StreamBuilder to display all tasks from Firestore in real-time
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 60,
                child: Flexible(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: searchTextController,
                          decoration:
                              const InputDecoration(hintText: 'Enter Search'),
                          onSubmitted: (String str) {
                            setState(() {
                              productList =
                                  buildProductList(searchTextController.text);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          rebuildProductList(searchTextController.text);
                          //searchTextController.text = '';
                        },
                        child: const Text('Load Product List'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            productList,
          ],
        ),
      ),
    );
  }

  Future<void> _productScreen(DocumentSnapshot prodSnap) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return ProductScreen(
              auth: widget.auth,
              userDocSnap: widget.userDocSnap,
              productSnap: prodSnap);
        });
  }

  Widget buildProductList(String searchText) {
    return Flexible(
      child: StreamBuilder(
        stream: searchText == ''
            ? _productss.snapshots()
            : _productss
                .where('product-name', isEqualTo: searchText)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                bool temp = true;
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    tileColor: Colors.grey,
                    leading: const Icon(Icons.image),
                    /*Image.network(
                      documentSnapshot['product-img-url'].toString(),
                      height: 25,
                      width: 25,
                    ),*/
                    title: Text(documentSnapshot['product-name']),
                    trailing: SizedBox(
                      width: 125,
                      child: Row(
                        children: [
                          /*IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white70,
                              ),
                              onPressed: () =>
                                  _decreaseProduct(documentSnapshot.id)),
                          countText(documentSnapshot.id), //i am having issues accessing user current cart doc.
                          */
                          IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                temp = !temp;
                                _addProductToCart(documentSnapshot);
                              }),
                          IconButton(
                              onPressed: () {
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => ShoppingCartScreen(
                                        auth: widget.auth,
                                        userDocSnap: widget.userDocSnap), //change to docref
                                  ),
                                );*/
                                _productScreen(
                                    documentSnapshot); //- call this when product screen function is done
                              },
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white70))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget countText(String productId) {
    final CollectionReference currentCart =
        _userss.doc(widget.userDocSnap.id).collection('current_cart');

    return FutureBuilder(
      future: currentCart.doc('products_$productId').get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        //Error Handling conditions
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("0");
        }

        //Data is output to the user
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Text("${data['count']}");
        }

        return const Text('Loading');
      },
    );
  }
}
