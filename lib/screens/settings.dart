import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projecttwo/screens/homescreen.dart';
import 'package:projecttwo/screens/shoppingcart.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(
      {Key? key, required this.auth, required this.userDocSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final CollectionReference _userss =
      FirebaseFirestore.instance.collection('users');

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    _firstNameController.text = documentSnapshot?['firstname'];
    _lastNameController.text = documentSnapshot?['lastname'];
    _addressController.text = documentSnapshot?['address'];
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile:'),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                //keyboardType://const TextInputType.numberWithOptions(decimal: true),
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('Update'),
                onPressed: () async {
                  final String firstname = _firstNameController.text;
                  final String lastname = _lastNameController.text;
                  final String address = _addressController.text;
                  //update user document
                  await _userss.doc(documentSnapshot!.id).update({
                    "firstname": firstname,
                    "lastname": lastname,
                    "address": address
                  });
                  //clear textfields
                  _firstNameController.text = '';
                  _lastNameController.text = '';
                  _addressController.text = '';
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _signOut() async {
    await widget.auth.signOut();
    if (kDebugMode) {
      print('signed out successfully');
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Signed out successfully'),
    ));
  }

  var firstname = '';
  var lastname = '';
  var address = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      //Fetching data from the documentId specified of the student
      future: _userss.doc(widget.userDocSnap.id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        //Error Handling conditions
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        //Data is output to the user
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          firstname = data['firstname'];
          lastname = data['lastname'];
          address = data['address'];
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shop EZ'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  _signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const MyHomePage(title: 'ShopEZ'),
                    ),
                  );
                },
                child: const Icon(Icons.logout),
              ),
            ],
          ),
          backgroundColor: Colors.black12,
          // Using StreamBuilder to display all tasks from Firestore in real-time
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                const Text(
                  'Settings',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 25),
                Text('First Name: $firstname',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 15),
                Text('Last Name: $lastname',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(
                  height: 15,
                ),
                Text('Address: $address',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 15),
                //I recommend adding the users orders on it.
                //You can do this by getting the orders collection reference and calling where() and snapshots()
                // I do this in buildProductList() where it asks for stream:
                ElevatedButton(
                  onPressed: () {
                    _update(widget.userDocSnap);
                  },
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                    onPressed: () {
                      _signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const MyHomePage(title: 'ShopEZ'),
                        ),
                      );
                    },
                    child: const Text('Sign Out')),
                const SizedBox(height: 25),
                const Text(
                  'Previous Purchases',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: buildPreviousPurchasesList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPreviousPurchasesList() {
    return Flexible(
      child: StreamBuilder(
        stream: _userss.doc(widget.userDocSnap.id).collection('past_orders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      tileColor: Colors.grey,
                      title: Text(documentSnapshot['orderID'].toString()),
                    ),
                  );
                },
              );
            } else {
                return const Center(
                  child: Text('No products purchased yet.'),
                );
            }
          /*return const Center(
            child: CircularProgressIndicator(),
          );*/
        },
      ),
    );
    /*return FutureBuilder<DocumentSnapshot>(
      future: _userss.doc(widget.userDocSnap.id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data);
          List<dynamic> previousOrders = snapshot.data!['previous-orders'];
          CollectionReference past_orders = _userss.doc(widget.userDocSnap.id).collection('past_orders');
          if (previousOrders.isNotEmpty) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: previousOrders.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      previousOrders[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No products purchased yet.'),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );*/
  }
}
