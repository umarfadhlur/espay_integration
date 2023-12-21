import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart' as crypto;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  crypto.RSAPublicKey publicKey;
  crypto.RSAPrivateKey privateKey;
  encrypt.Encrypter encrypter;
  String plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  String encryptedText, decryptedText, encryptedString;
  bool benarTidak;

  final privateKeyFile = '''-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA2O9xDMTBiZ5oOy3LBVn6TerxWMHEwxl6gr0SX1dRt4be5vq2
voFMoCHokeowqpeU5ZQi0EM36W7Q1K8hH6KRjdNqhdIHyMh7X0yhVJTQ3Fz9QcjB
feMwoovmIYHP+U08GKz7j99VojSSriYvzT1mPdwvTuAdFT3QEXfgdMLKQCjtXF/e
yg2Q+xCYJALv+zeaPlsu00RO3TM5NGaCSbFCoF/xa4IOfV+215beBvl1fUhW6mkE
o7gdhK8T0ddk5bInEJs3YzDwQNtAutLEFVotEKX2ETqIk8S1H7Pou7tSo73O0fFG
aSBhG610bKIb9lLTXCQYJKk8bygPaL3aoT+5QwIDAQABAoIBAQDTSPIcc43kUWpH
KSSxQ59sQEVsIt1W//u4VhoMzekDDNMQuGNATIKq/Bud8jAQFq6oo4z8tltAefPf
Eer6+sU1ExKO369BOTIf8Wy4CnEaD1+CsNrzl1EJH6S2Qc6jizva9K/WwriO0RGD
mCG6jfCEk21oLxNkWt3KBa2RSx7dOLO+ct07jtRbfYCVCAezyx6fWxLJ6eVmGZXM
kOhAr9tQ6IC3v/iQgA00LNPXR+X12obcmNXtcng5uHffeZNr6tmpLpXTYLdwZlwl
FINuTGpPjp1yy6q6GQYphF51ywRFN17g8NoVHLXDAfnrmB1lgtbC3nSiAvqEq2c6
XQkAIZbBAoGBAPgQDtG7RJ/Wdo5ra9HMgceVqDQgrdY4vw4cnV4NVGSBGn8jNhk7
YrJ8siJbLxqi5cPwJzu7xS8krKyt3vBY8AFKvVJ9yZ06VVL4d2LvWr50ym/zshnC
w1WlKhcuyaqP6MCiC6pZNA5LR1AN6hK2B1ZnmSrvDkg+MZtGTAxJrF6TAoGBAN/g
aVtaHuw1Zh2ixRfUjjQ4YMSxt/68DnmAJemmWQysvFsTZLfy87KLenmLABnG9qke
sOLD/vC7h5s5G9+vN4JMbmTYGBYp0VW5wWaC7Nw8cskgsmb7BZ+K7HsQbmtxh9Nu
BeQqdmQHZvLQ6wgY+0QTy/1KTUPwxLztyJttGjiRAoGAQEkpDgFSD3osz0vXbU9q
cqa+KIQviMy79pRD1BPwQvuSOlCNvIw/T7IxF+Y5ltWQZe7evAQ1XbpLZZTJqc/i
ovMTjUU78psjcZUim2kcQy9RJyIojbSDmrZq6gceDC2vS/yyuTrU2r93g6+XcbHq
xOGkOBQrx10Wzf6xxp1xJjECgYBfSk6t4nsdAVGYtap8jS2GDqUps5dkZrkmgCQj
AnoOygtWHLgXD+MokPOtfjupvSVKMNULgG8oGjoLGNDDcfoHjO7EH7KI5H3Epk8q
ifm1eElHUJJ/AMOQ9/nWG9VUCDvPA5qgVm6T/w6TtdcEWFXC0UZXZmPi0j17SR7F
AThS8QKBgQCCyPFJzwGIP99PcakQ38oFcoU8u/ahb0ghgJfSgK+K/ChXSyfbq5zt
jRkj6UWLa3plYX3po9h0Yp6f2IxnbOa3VK6fPkcSvBxhgK3RrugPerUJzFEPd3k4
GTqOBXtXO6N7zEMYxZxv0SgrV24LPfPz0aPObDeH6F0kuzXjanopIw==
-----END RSA PRIVATE KEY-----''';
  final publicKeyFile = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2O9xDMTBiZ5oOy3LBVn6
TerxWMHEwxl6gr0SX1dRt4be5vq2voFMoCHokeowqpeU5ZQi0EM36W7Q1K8hH6KR
jdNqhdIHyMh7X0yhVJTQ3Fz9QcjBfeMwoovmIYHP+U08GKz7j99VojSSriYvzT1m
PdwvTuAdFT3QEXfgdMLKQCjtXF/eyg2Q+xCYJALv+zeaPlsu00RO3TM5NGaCSbFC
oF/xa4IOfV+215beBvl1fUhW6mkEo7gdhK8T0ddk5bInEJs3YzDwQNtAutLEFVot
EKX2ETqIk8S1H7Pou7tSo73O0fFGaSBhG610bKIb9lLTXCQYJKk8bygPaL3aoT+5
QwIDAQAB
-----END PUBLIC KEY-----''';

  @override
  void initState() {
    super.initState();

    // Inisialisasi kunci pada saat widget dibuat
    publicKey = encrypt.RSAKeyParser().parse(publicKeyFile);
    privateKey = encrypt.RSAKeyParser().parse(privateKeyFile);

    // Contoh enkripsi
    final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    encryptedText = sign(plainText, privateKey);

    benarTidak = verifySignature(plainText, encryptedText, publicKey);

    // Output ke terminal
    print('Plain Text: $plainText');
    print('Encrypted Text: $encryptedText');
  }

  String sign(String plainText, crypto.RSAPrivateKey privateKey) {
    var signer = RSASigner(SHA256Digest(), '0609608648016503040201');
    signer.init(true, PrivateKeyParameter<crypto.RSAPrivateKey>(privateKey));
    return base64Encode(
        signer.generateSignature(createUint8ListFromString(plainText)).bytes);
  }

  Uint8List createUint8ListFromString(String s) {
    var codec = Utf8Codec(allowMalformed: true);
    return Uint8List.fromList(codec.encode(s));
  }

  static bool verifySignature(
      String data, String signature, crypto.RSAPublicKey publicKey) {
    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
    verifier.init(false, PublicKeyParameter<crypto.RSAPublicKey>(publicKey));

    final Uint8List signatureBytes = base64Decode(signature);
    return verifier.verifySignature(
        Uint8List.fromList(utf8.encode(data)), RSASignature(signatureBytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encrypted Text: $encryptedText'),
            Text('Decrypted Text: $decryptedText'),
            Text('Signature Verified: $benarTidak'),
          ],
        ),
      ),
    );
  }
}
