import 'dart:math';

String generateRandomNumericString() {
  DateTime currentDate = DateTime.now();
  String dateString = currentDate.toIso8601String().substring(0, 10);
  String randomNumericString =
      generateRandomDigits(25 - dateString.length).join();
  String result = '$dateString-$randomNumericString';

  return result.substring(0, 25);
}

List<String> generateRandomDigits(int count) {
  final random = Random();
  return List.generate(count, (index) => random.nextInt(10).toString());
}
