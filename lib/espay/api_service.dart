import 'dart:convert';
import 'package:espay_integration/espay/generate_random_string.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = "https://sandbox-api.espay.id";

  static Future<Map<String, dynamic>> makeApiRequest(
      String path, Map<String, dynamic> requestBody) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final url = Uri.parse('$baseUrl/$path');

    var jsonObject = json.decode(requestBody.toString());
    var minifiedJson = json.encode(jsonObject);
    print('jsonObject: $jsonObject');
    print('minifiedJson: $minifiedJson');
    String stringTosign = 'post:$path:';
    String generateSignature() {
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
