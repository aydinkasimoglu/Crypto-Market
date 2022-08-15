class CryptoModel {
  final String currency;
  final String price;
  final String logoUrl;
  final String priceChangePct;

  const CryptoModel({required this.currency, required this.price, required this.logoUrl, required this.priceChangePct});

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(
        currency: json['symbol'],
        price: json['current_price'].toString(),
        logoUrl: json['image'],
        priceChangePct: json['price_change_percentage_24h'].toString());
  }

  Map<String, dynamic> toJson() =>
      {'symbol': currency, 'current_price': price, 'image': logoUrl, 'price_change_percentage_24h': priceChangePct};

  @override
  String toString() {
    return 'CryptoModel{currency: $currency, price: $price, logoUrl: $logoUrl, priceChangePct: $priceChangePct}';
  }
}
