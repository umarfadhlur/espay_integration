import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:espay_integration/ui/api_access_page.dart';
import 'package:espay_integration/ui/images_page.dart';
import 'package:espay_integration/ui/test_page.dart';
import 'package:espay_integration/utils/dependency_provider.dart';
import 'package:flutter/material.dart';
import 'package:espay_integration/ui/home_page.dart';
import 'package:pointycastle/asymmetric/api.dart';

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
      // home: ImagesPage(),
      home: ApiAccessPage(),
      // home: TestPage(title: 'RSA Key Generator'),
      // home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
