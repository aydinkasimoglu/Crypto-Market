class CryptoModel {
  final String currency;
  final String price;
  final String logoUrl;
  final String priceChangePct;

  const CryptoModel({required this.currency, required this.price, required this.logoUrl, required this.priceChangePct});

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
        currency: json['currency'],
        price: json['price'],
        logoUrl: json['logo_url'],
        priceChangePct: json['1d']['price_change_pct']);
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
