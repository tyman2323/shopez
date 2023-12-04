import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key, required this.auth, required this.userDocSnap});


  final FirebaseAuth auth;
  final DocumentSnapshot userDocSnap;
  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
