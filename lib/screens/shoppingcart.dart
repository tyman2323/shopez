import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/productscreen.dart';
import 'package:projecttwo/screens/sellersdashboard.dart';
import 'package:projecttwo/screens/settings.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen(
      {Key? key, required this.auth, required this.userDocSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreen();
}

class _ShoppingCartScreen extends State<ShoppingCartScreen> {
  double totalCost = 0.0;
// text fields' controllers
  final SearchController _searchController = SearchController(); //textediting?

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
    try {
      await docRef.update({'count': FieldValue.increment(1)});
    } on Exception catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Checkout Page'),
        actions: <Widget>[
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
      //backgroundColor: Colors.black12,
// Using StreamBuilder to display all tasks from Firestore in real-time
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(height: 60, child: buildSearchBar())),
            buildProductList(_searchController.text),
            Text("Total Cost: $totalCost")
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    //bool isDark = false;
    //final ThemeData themeData = ThemeData(useMaterial3: true, brightness: isDark ? Brightness.dark : Brightness.light);

    return SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
      return SearchBar(
        controller: _searchController,
        padding: const MaterialStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0)),
        onTap: () {
          _searchController.openView();
        },
        onChanged: (_) {
          _searchController.openView();
        },
        leading: const Icon(Icons.search),
        /*trailing: <Widget>[
              Tooltip(message: 'Change brightness mode', child: IconButton(
                  isSelected: isDark,
                  onPressed: () {
                    setState(() {
                      isDark = !isDark;
                    });
                  },
                  icon: const Icon(Icons.wb_sunny_outlined),
                  selectedIcon: const Icon(Icons.brightness_2_outlined),
                ),
              )
            ],*/
      );
    }, suggestionsBuilder: (BuildContext context, SearchController controller) {
      return List<ListTile>.generate(5, (int index) {
        final String item = 'item $index';
        return ListTile(
          title: Text(item),
          onTap: () {
            setState(() {
              _searchController.closeView(item);
            });
          },
        );
      });
    });
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
            totalCost = 0;
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                print("Failing here");

                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return FutureBuilder<int>(
                  future: getCountText(documentSnapshot.id),
                  builder: (context, AsyncSnapshot<int> countSnapshot) {
                    if (countSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (countSnapshot.hasError) {
                      return Text('Error: ${countSnapshot.error}');
                    } else {
                      int count = countSnapshot.data!;
                      if (streamSnapshot.data!.docs.isNotEmpty && count > 0) {
                        totalCost += documentSnapshot["product-price"];
                      }
                      // Use count to build your UI here
                      return (streamSnapshot.data!.docs.isNotEmpty && count > 0)
                          ? Card(
                              margin: const EdgeInsets.all(10),
                              child: (documentSnapshot.get('product-img-url') !=
                                          null &&
                                      documentSnapshot.get('product-img-url') !=
                                          null)
                                  ? ListTile(
                                      tileColor: Color(0xFFe2f3f7),
                                      leading: Image.network(
                                        documentSnapshot['product-img-url'],
                                        height: 25,
                                        width: 25,
                                      ),
                                      title: Text(
                                        (documentSnapshot.get("product-name") !=
                                                null)
                                            ? documentSnapshot['product-name']
                                            : "",
                                      ),
                                      trailing: SizedBox(
                                        width: 175,
                                        child: Column(children: [
                                          Row(
                                            children: [
                                              const Text("Quantity "),
                                              Text(count
                                                  .toString()), // Use count here
                                              const Text(" Item Price: "),
                                              Text(documentSnapshot[
                                                      "product-price"]
                                                  .toString()),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Text(" Cost: "),
                                              Text((documentSnapshot[
                                                          "product-price"] *
                                                      count)
                                                  .toString()),
                                            ],
                                          )
                                        ]),
                                      ),
                                    )
                                  : const ListTile(
                                      tileColor: Color(0xFFFF0000),
                                      title: Text("No product image"),
                                    ),
                            )
                          : const SizedBox
                              .shrink(); // Returning an empty widget when count is not greater than 0
                    }
                  },
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

  Future<int> getCountText(String productId) async {
    final CollectionReference currentCart =
        _userss.doc(widget.userDocSnap.id).collection('current_cart');

    try {
      DocumentSnapshot snapshot =
          await currentCart.doc('products_$productId').get();

      if (!snapshot.exists) {
        return 0;
      }

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['count'] ?? 0;
    } catch (e) {
      print("Error: $e");
      return 0; // You can handle errors as needed
    }
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
