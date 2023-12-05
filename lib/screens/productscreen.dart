import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key, required this.auth, required this.userDocSnap, required this.productSnap})
      : super(key: key);

  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;
  final DocumentSnapshot productSnap;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  //reference to products collection
  final CollectionReference _productss =
  FirebaseFirestore.instance.collection('products');

  //reference to user collection - will use this to get count of product in cart if exists
  final CollectionReference _userss =
  FirebaseFirestore.instance.collection('users');

  //increase product count
  Future<void> _increaseProduct(String productId) async {
    final CollectionReference currentCart = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocSnap.id)
        .collection('current_cart');
    DocumentReference docRef = currentCart.doc('products_$productId');
    if (docRef != null) {
      await docRef.update({'count': FieldValue.increment(1)});
    } else {
      await currentCart.doc('products_$productId').set({'count': 1});
    }
  }

  //decrease product count
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


  ///because this is a function... when the arrow button on a specific product
  ///is pressed on the home screen, I would call this function sending in the chosen products information and a bottom
  ///modal will pop up with the information displayed
  Future<void> _addUserReview(String review) async {
    CollectionReference userReviews = _productss.doc(widget.productSnap.id).collection('userreviews');

    var name = widget.userDocSnap['firstname'] + ' ' + widget.userDocSnap['lastname'];
    userReviews.add({'uid' : widget.userDocSnap.id, 'username' : name, 'review' : review, 'post_time' : Timestamp.fromDate(DateTime.now())});
  }

  Future<void> _productReviewsModalSheet([DocumentSnapshot? documentSnapshot]) async {

    //this is a reference to the specified products list of user reviews
    CollectionReference userReviews = _productss.doc(documentSnapshot?.id).collection('userreviews');

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${documentSnapshot?['product-name']} Reviews'),
                const SizedBox(height: 10),
                ElevatedButton(
                    onPressed: (){
                      //add text field to insert review into user_reviews collection
                      // call _addUserReview(review) to add the review to the database on submit
                    },
                    child: const Text('Add Review')),
                Flexible(
                    child: StreamBuilder( //use to display user reviews; display user name and review and date
                      stream: userReviews.snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return ListView.builder(
                            itemCount: streamSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                              return Card(
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  title: Text('Put the review here'), //add their name too... and maybe the date
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
                ),
              ],
            ),
          );
        });
  }



  /// This will be inside of a showModalBottomSheet Function
  @override
  Widget build(BuildContext context) {

    String product_name = '';
    var product_imag_url = '';
    var product_price = '';
    var product_rating = '';
    var product_desc = '';
    if (widget.productSnap != null) {
      product_name = widget.productSnap['product-name'];
      //product_imag_url = widget.productSnap['product-img'];
      // I believe you made this an array in the database, so you can figure out a way to acces the image url
      // for now i will leave the url as an empty string
      product_price = widget.productSnap['product-price'].toString();
      product_rating = widget.productSnap['product-rating'].toString();
      product_desc = widget.productSnap['product-description'];
    }

    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product_name, style: const TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(
            height: 20,
          ),
          Image.asset(product_imag_url, height: 300, width: 300),
          const SizedBox(height: 20),
          Text('Price: \$$product_price'),
          const SizedBox(height: 20),
          Text('Average Rating: $product_rating'),
          const SizedBox(height: 20),
          Text('Product Description: $product_desc'),
          const SizedBox(height: 20),
          ElevatedButton(
            //you can use this button to show/build the user reviews, it would make the page longer
            //you can either make display them on the same page or navigate to another page to display it
            //on that page or modal sheet you can have another button that allows the user to add their review
            //use this button to pull up a text field that allows a user to input a review of the product
            //review is made of two parts - rating a text; it can be just a rating or both
            //I was looking at the walmart app and they use a bottomModalSheet to display a specific product
            //and clicking the user reviews pulls up another page in the modal. you can do it like that

              onPressed: () {
                _productReviewsModalSheet(); //this calls the function that displays modal with user reviews
              },
              child: const Text('Reviews'))

        ],
      ),
    );
  }
}
