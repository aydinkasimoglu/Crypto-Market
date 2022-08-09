const String tableCryptoTransaction = 'crypto_transaction';

class CryptoTransactionFields {
  static const List<String> values = [
    id,
    currency,
    price,
    amount,
    date,
    type,
  ];

  static const String currency = 'currency';
  static const String price = 'price';
  static const String amount = 'amount';
  static const String date = 'date';
  static const String type = 'type';
  static const String id = '_id';
}

class CryptoTransaction {
  final String currency;
  final double price;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final int? id;

  const CryptoTransaction({
    required this.currency,
    required this.price,
    required this.amount,
    required this.date,
    required this.type,
    this.id,
  });

  CryptoTransaction copyWith({
    String? currency,
    double? price,
    double? amount,
    DateTime? date,
    TransactionType? type,
    int? id,
  }) {
    return CryptoTransaction(
      currency: currency ?? this.currency,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  factory CryptoTransaction.fromJson(Map<String, dynamic> json) {
    return CryptoTransaction(
      currency: json[CryptoTransactionFields.currency],
      price: json[CryptoTransactionFields.price],
      amount: json[CryptoTransactionFields.amount],
      date: DateTime.parse(json[CryptoTransactionFields.date]),
      type: TransactionType.values.firstWhere(
        (type) => type.toString() == json[CryptoTransactionFields.type],
        orElse: () => TransactionType.buy,
      ),
      id: json[CryptoTransactionFields.id],
    );
  }

  Map<String, dynamic> toJson() => {
        CryptoTransactionFields.currency: currency,
        CryptoTransactionFields.price: price,
        CryptoTransactionFields.amount: amount,
        CryptoTransactionFields.date: date.toIso8601String(),
        CryptoTransactionFields.type: type.index.toString(),
        CryptoTransactionFields.id: id,
      };
}

enum TransactionType {
  buy,
  sell,
}
