import 'dart:convert';

class CryptoModel {
  final String currency;
  final String price;
  final String logoUrl;
  final String priceChangePct;

  const CryptoModel({required this.currency, required this.price, required this.logoUrl, required this.priceChangePct});

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    final oneDay = jsonEncode(json['1d']);
    if (jsonDecode(oneDay) != null) {
      Map<String, dynamic> oneDayMap = jsonDecode(oneDay);

      return CryptoModel(
          currency: json['currency'],
          price: json['price'],
          logoUrl: json['logo_url'],
          priceChangePct: oneDayMap['price_change_pct']);
    } else {
      return CryptoModel(
          currency: json['currency'], price: json['price'], logoUrl: json['logo_url'], priceChangePct: 'NaN');
    }
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'price': price,
        'logo_url': logoUrl,
        '1d': {'price_change_pct': priceChangePct}
      };

  @override
  String toString() {
    return 'CryptoModel{currency: $currency, price: $price, logoUrl: $logoUrl, priceChangePct: $priceChangePct}';
  }
}
