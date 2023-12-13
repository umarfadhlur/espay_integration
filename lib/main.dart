import 'package:espay_integration/espay/dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:espay_integration/ui/home_page.dart';

void main() {
  // We need to encapsulate `MyApp` with the DependencyProvider in order
  // to be able to access the RSA KeyHelper
  runApp(DependencyProvider(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
