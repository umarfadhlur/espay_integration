import 'dart:typed_data';

import 'package:espay_integration/utils/rsa_key.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:espay_integration/utils/generate_random_string.dart';

class ApiAccessPage extends StatefulWidget {
  @override
  _ApiAccessPageState createState() => _ApiAccessPageState();
}

class _ApiAccessPageState extends State<ApiAccessPage> {
  Map<String, dynamic> responseData;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Access Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _makeApiRequest,
              child: Text('Access API'),
            ),
            // ... (Add widgets to display response or error)
            Container(
              width: double.infinity,
              height: 200,
              child: Center(
                child:
                    Text(responseData != null ? responseData.toString() : ""),
              ),
            ),
            Text(errorMessage),
          ],
        ),
      ),
    );
  }

  void _makeApiRequest() async {
    setState(() {
      errorMessage = ""; // Clear any previous error message
    });
    try {
      final timestamp = DateTime.now().toUtc().toIso8601String();
      Map<String, dynamic> requestBody = {
        "partnerReferenceNo": generateRandomNumericString(),
        "merchantId": "SGWROYALABADISEJ",
        "amount": {"value": "10001.00", "currency": "IDR"},
        "additionalInfo": {"productCode": "QRIS"}
      };
      print(jsonEncode(requestBody));
      final hexEncode = hexEncodeSHA256(jsonEncode(requestBody)).toLowerCase();
      print(hexEncode);
      final stringToSign =
          "POST:/api/v1.0/qr/qr-mpm-generate:$hexEncode:$timestamp"; // Adjust path if needed
      print(stringToSign);
      final signature = generateSignature(
          stringToSign, privateKey); // Assuming you have this function

      final headers = {
        'Content-Type': 'application/json',
        'X-TIMESTAMP': timestamp,
        'X-SIGNATURE': signature,
        'X-EXTERNAL-ID':
            generateRandomNumericString(), // Assuming you have this function
        'X-PARTNER-ID': 'SGWROYALABADISEJ',
        'CHANNEL-ID': 'ESPAY',
      };

      final response = await http.post(
        Uri.parse(
            'https://sandbox-api.espay.id/api/v1.0/qr/qr-mpm-generate'), // Adjust URL if needed
        headers: headers,
        body: jsonEncode(requestBody),
      );

      responseData = jsonDecode(response.body);
      // Handle successful response (e.g., display data)
      setState(() {
        errorMessage = "";
        print(responseData);
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString(); // Display error message
        print(errorMessage);
      });
    }
  }
}
