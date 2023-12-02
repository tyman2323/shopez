import 'package:flutter/material.dart';
import 'package:projecttwo/homescreen.dart';

class splashscreen extends StatefulWidget {
  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    navigatetohome();
  }

  navigatetohome() async {
    await Future.delayed(
      Duration(seconds: 3),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => homescreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text(
                'You\'re about to enter ShopEz',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox.fromSize(
                  size: Size.fromRadius(150), // Image radius
                  child: Image.network(
                      'https://media.tenor.com/YjuxAL4URQ0AAAAC/floating-shopping-cart.gif',
                      fit: BoxFit.cover),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
