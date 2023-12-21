import 'dart:convert';

import 'package:espay_integration/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:espay_integration/utils/dependency_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle get whiteTextStyle => TextStyle(color: Colors.white);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> futureText;
  String _publicKey, _privateKey;

  /// Future to hold the reference to the KeyPair generated with PointyCastle
  /// in order to extract the [crypto.PrivateKey] and [crypto.PublicKey]
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      futureKeyPair;

  /// The current [crypto.AsymmetricKeyPair]
  crypto.AsymmetricKeyPair keyPair;

  /// With the helper [RsaKeyHelper] this method generates a
  /// new [crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    var keyHelper = DependencyProvider.of(context).getRsaKeyHelper();
    return keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
  }

  /// GlobalKey to be used when showing the [Snackbar] for the successful
  /// copy of the Key
  final key = new GlobalKey<ScaffoldState>();

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MaterialButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Generate new Key Pair",
                  style: whiteTextStyle,
                ),
                onPressed: () {
                  setState(() {
                    // If there are any pemString being shown, then show an empty message
                    futureText = Future.value("");
                    // Generate a new keypair
                    futureKeyPair = getKeyPair();
                  });
                },
              ),
              Expanded(
                flex: 1,
                child: FutureBuilder<
                        crypto.AsymmetricKeyPair<crypto.PublicKey,
                            crypto.PrivateKey>>(
                    future: futureKeyPair,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // if we are waiting for a future to be completed, show a progress indicator
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        // Else, store the new keypair in this state and sbow two buttons
                        this.keyPair = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            MaterialButton(
                              color: Colors.red,
                              child: Text("Get Private Key",
                                  style: whiteTextStyle),
                              onPressed: () {
                                setState(() {
                                  // With the stored keypair, encode the private key to
                                  // PKCS1 and show it
                                  futureText = Future.value(
                                      DependencyProvider.of(context)
                                          .getRsaKeyHelper()
                                          .encodePrivateKeyToPemPKCS1(
                                              keyPair.privateKey));
                                  _privateKey = DependencyProvider.of(context)
                                      .getRsaKeyHelper()
                                      .encodePrivateKeyToPemPKCS1(
                                          keyPair.privateKey);
                                  print(_privateKey);
                                });
                              },
                            ),
                            MaterialButton(
                              color: Colors.green,
                              child:
                                  Text("Get Public Key", style: whiteTextStyle),
                              onPressed: () {
                                setState(() {
                                  // With the stored keypair, encode the public key to
                                  // PKCS1 and show it
                                  futureText = Future.value(
                                      DependencyProvider.of(context)
                                          .getRsaKeyHelper()
                                          .encodePublicKeyToPemPKCS1(
                                              keyPair.publicKey));
                                  _publicKey = DependencyProvider.of(context)
                                      .getRsaKeyHelper()
                                      .encodePublicKeyToPemPKCS1(
                                          keyPair.publicKey);
                                  print(keyPair.publicKey);
                                });
                              },
                            ),
                            TextField(
                              decoration:
                                  InputDecoration(hintText: "Text to Sign"),
                              controller: _controller,
                            ),
                            MaterialButton(
                              color: Colors.black87,
                              child: Text("Sign Text", style: whiteTextStyle),
                              onPressed: () {
                                setState(() {
                                  futureText = Future.value(
                                      DependencyProvider.of(context)
                                          .getRsaKeyHelper()
                                          .sign(_controller.text,
                                              keyPair.privateKey));
                                });
                              },
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }),
              ),
              Expanded(
                flex: 2,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(8),
                    child: FutureBuilder(
                        future: futureText,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return SingleChildScrollView(
                              // the inkwell is used to register the taps
                              // in order to be able to copy the text
                              child: InkWell(
                                  onTap: () {
                                    // Copies the data to the keyboard
                                    Clipboard.setData(
                                        new ClipboardData(text: snapshot.data));
                                    key.currentState.showSnackBar(new SnackBar(
                                      content: new Text("Copied to Clipboard"),
                                    ));
                                  },
                                  child: Text(snapshot.data)),
                            );
                          } else {
                            return Center(
                              child: Text("Your keys will appear here"),
                            );
                          }
                        }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
