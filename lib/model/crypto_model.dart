class CryptoModel {
  final String currency;
  final String price;

  const CryptoModel({
    required this.currency,
    required this.price,
  });

  factory CryptoModel.fromJson(Map<String, dynamic> json) {
    return CryptoModel(currency: json['currency'], price: json['price']);
  }

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'price': price,
  };
}