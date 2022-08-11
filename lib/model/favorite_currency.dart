const String tableFavoriteCurrency = 'favorite_currency';

class FavoriteCurrencyFields {
  static const List<String> values = [
    id,
    currency,
  ];
  static const String currency = 'currency';
  static const String id = '_id';
}

class FavoriteCurrency {
  final String currency;
  final int? id;

  const FavoriteCurrency({
    required this.currency,
    this.id,
  });

  FavoriteCurrency copyWith({
    String? currency,
    double? price,
    String? logoUrl,
    double? priceChangePct,
    int? id,
  }) {
    return FavoriteCurrency(
      currency: currency ?? this.currency,
      id: id ?? this.id,
    );
  }

  factory FavoriteCurrency.fromJson(Map<String, dynamic> json) {
    return FavoriteCurrency(
      currency: json[FavoriteCurrencyFields.currency],
      id: json[FavoriteCurrencyFields.id],
    );
  }

  Map<String, dynamic> toJson() => {
        FavoriteCurrencyFields.currency: currency,
        FavoriteCurrencyFields.id: id,
      };
}
