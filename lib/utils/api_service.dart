import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:espay_integration/utils/generate_random_string.dart';
import 'package:espay_integration/utils/rsa_key_helper.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart' as crypto;

final rsaKeyHelper = RsaKeyHelper();

class ApiService {
  crypto.RSAPublicKey publicKey;
  crypto.RSAPrivateKey privateKey;
  encrypt.Encrypter encrypter;
  String plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  encrypt.Encrypted encryptedText;
  String decryptedText, encryptedString;

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

  static const baseUrl = "https://sandbox-api.espay.id";
  static const pathQR = "/api/v1.0/qr/qr-mpm-generate";
  static const httpMethod = "POST";

  static Future<Map<String, dynamic>> makeApiRequest(
      String path, Map<String, dynamic> requestBody) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final url = Uri.parse('$baseUrl/$path');

    var jsonObject = json.decode(requestBody.toString());
    var minifiedJson = json.encode(jsonObject);
    print('jsonObject: $jsonObject');
    print('minifiedJson: $minifiedJson');

    String hexEncodeSHA256(String jsonBody) {
      var bytes = utf8.encode(jsonBody);
      var digest = sha256.convert(bytes);

      return digest.toString();
    }

    String hexEncode = hexEncodeSHA256(minifiedJson).toLowerCase();

    String stringToSign = "$httpMethod:$pathQR:$hexEncode:$timestamp";

    //HTTPMethod+":"+RelativeUrl+":"
    //+Lowercase(HexEncode(SHA-256(MinifyJson(RequestBody))))
    //+":"+Timestamp

    String generateSignature() {
      // rsaKeyHelper.sign(stringToSign, '');
      return 'your-generated-signature';
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-TIMESTAMP': timestamp,
      'X-SIGNATURE': generateSignature(),
      'X-EXTERNAL-ID': generateRandomNumericString(),
      'X-PARTNER-ID': 'SGWROYALABADISEJ',
      'CHANNEL-ID': 'ESPAY',
      if (shouldIncludeAccessToken())
        'Authorization-Customer': 'your-access-token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    return jsonDecode(response.body);
  }

  static bool shouldIncludeAccessToken() {
    return true;
  }
}
