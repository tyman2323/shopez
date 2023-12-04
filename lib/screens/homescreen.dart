import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/settings.dart';
import 'package:projecttwo/screens/shoppingcart.dart';
import '/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.auth, required this.userDocSnap}) : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// text fields' controllers
  final SearchController _searchController = SearchController(); //textediting?

  final CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference _userss =
  FirebaseFirestore.instance.collection('users');


  //changing complete by id bool _value = false;
  Future<void> _completeTask([DocumentSnapshot? documentSnapshot]) async {
    var name = "";
    var content = "";

    if (documentSnapshot != null) {
      name = documentSnapshot['name'];
      content = documentSnapshot['content'].toString();
      await _productss.doc(documentSnapshot.id).update({
        "name": name,
        "content": content,
        "complete": !documentSnapshot['complete']
      });
    }
    /*
      final String name2 = name;
      final String content2 = content;

      if (content != null) {
// Update the task
          await _taskss
              .doc(documentSnapshot!.id)
              .update({"name": name2, "content": content2, "complete" : !documentSnapshot['complete']});
      }*/
  }

  Future<void> _increaseProduct(String productId) async {
    final CollectionReference currentCart =  FirebaseFirestore.instance.collection('users').doc(widget.userDocSnap.id).collection('current_cart');
    DocumentReference docRef =  currentCart.doc('products_$productId');
    if(docRef != null){
      await docRef.update({'count': FieldValue.increment(1)});
    }else{
      await currentCart.doc('products_$productId').set({'count' : 1});
    }

  }

  Future<void> _decreaseProduct(String productId) async {
    final CollectionReference currentCart =  FirebaseFirestore.instance.collection('users').doc(widget.userDocSnap.id).collection('current_cart');
    DocumentReference docRef =  currentCart.doc('products_$productId');
    if(docRef != null){
      DocumentSnapshot docSnap = await docRef.get();
      if(docSnap['count'] == 1){
        await currentCart.doc(docSnap.id).delete();
      }
    }
    await docRef.update({'count': FieldValue.increment(-1)});
  }

  Future<void> _getCount() async {

  }

  void _signOut() async {
    await widget.auth.signOut();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Signed out successfully'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop EZ'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ShoppingCartScreen(
                      auth: widget.auth, userDocSnap: widget.userDocSnap), //change to docref
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
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      backgroundColor: Colors.black12,
// Using StreamBuilder to display all tasks from Firestore in real-time
      body: SafeArea(
        child:
          Column(
            children: [
              SizedBox(
                  height: 50,
                  child: buildSearchBar()
              ),
              buildProductList(_searchController.text),
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
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
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
          }
          );
      }
    );
  }

  Widget buildProductList(String searchText) {
    return Flexible(
        child: StreamBuilder(
          stream: _productss.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              final product_count = 1;
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  //DocumentReference currentDocRef = _userss.doc(widget.userDocSnap.id).collection('current_cart').doc('products_${documentSnapshot.id}');

                  int count = 0;
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      tileColor: Colors.grey,
                      leading: Image.asset(documentSnapshot['image_url'].toString(), height: 25, width: 25,),
                      title: Text(documentSnapshot['name']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    _decreaseProduct(documentSnapshot.id)),
                            const Text('0'), //i am having issues accessing user current cart doc.
                            IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    _increaseProduct(documentSnapshot.id)),
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
}
