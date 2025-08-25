import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sushiaya/screens/cartPro.dart';

import 'package:sushiaya/screens/intro1.dart'; // or whatever your intro screen file is

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sushiaya',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: const intro1(), // Your intro screen
      ),
    );
  }
}
