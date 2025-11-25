import 'dart:math';
class MarketService {
  Future<double> getEstimatedPrice(String name) async {
    await Future.delayed(const Duration(seconds: 2));
    final random = Random();
    double base = 80.0;
    if (name.toLowerCase().contains('jordan')) base = 200.0 + random.nextInt(300);
    return base.roundToDouble();
  }
}