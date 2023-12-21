import 'package:flutter/material.dart';

class ImagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Image Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gambar dari Asset:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Menampilkan gambar dari asset
            Image.asset(
              'testAssets/images.jpg', // Ubah sesuai nama file gambar di folder assets
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
