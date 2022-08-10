import 'package:crypto_market/db/transaction_database.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

import '../components/custom_text_field.dart';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(<K, List<E>>{},
      (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

class CoinDetailsPage extends StatefulWidget {
  const CoinDetailsPage({Key? key, required this.currency, required this.price}) : super(key: key);

  final String currency;
  final String price;

  @override
  State<CoinDetailsPage> createState() => _CoinDetailsPageState();
}

class _CoinDetailsPageState extends State<CoinDetailsPage> {
  late TextEditingController _coinController;
  late TextEditingController _dollarController;
  double coinAmount = 0.0;
  bool isBuyingState = true;
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _coinController = TextEditingController();
    _dollarController = TextEditingController();
    loadTransactions();
  }

  @override
  void dispose() {
    super.dispose();
    _coinController.dispose();
    _dollarController.dispose();
  }

  void loadTransactions() async {
    final transactions = await TransactionDatabase.instance.getTransactions();
    final groupedTransactions = transactions.groupBy((t) => t.currency);
    final index = groupedTransactions.keys.toList().indexOf(widget.currency);
    if (index != -1) {
      final list = groupedTransactions.values.toList()[index];

      for (var element in list) {
        setState(() {
          coinAmount += element.type == TransactionType.buy ? element.amount : -element.amount;
        });
      }
    }
  }

  void onCoinAmountChanged(String value) {
    try {
      if (value.isEmpty) {
        setState(() {
          isButtonDisabled = true;
        });
      } else if (double.parse(value) == 0.0) {
        setState(() {
          isButtonDisabled = true;
        });
      } else {
        setState(() {
          isButtonDisabled = false;
        });
      }

      setState(() {
        double x = double.parse(value) * double.parse(widget.price);
        _dollarController.text = x.toStringAsFixed(3);
      });
    } on Exception catch (_, e) {
      debugPrint(e.toString());
    }
  }

  void onDollarAmountChanged(String value) {
    try {
      if (value.isEmpty) {
        setState(() {
          isButtonDisabled = true;
        });
      } else if (double.parse(value) == 0.0) {
        setState(() {
          isButtonDisabled = true;
        });
      } else {
        setState(() {
          isButtonDisabled = false;
        });
      }

      setState(() {
        double x = double.parse(value) / double.parse(widget.price);
        _coinController.text = x.toStringAsFixed(3);
      });
    } on Exception catch (_, e) {
      debugPrint(e.toString());
    }
  }

  void displaySnackBar(String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Create a buying transaction and add it to the database.
  /// Then display a snackbar with a success message.
  void onAddToWalletClicked() async {
    final crypto = await TransactionDatabase.instance.create(CryptoTransaction(
        currency: widget.currency,
        price: double.parse(widget.price),
        amount: double.parse(_coinController.text),
        date: DateTime.now(),
        type: TransactionType.buy));

    setState(() {
      coinAmount += crypto.amount;
    });

    displaySnackBar('${crypto.amount} ${crypto.currency} added to wallet');
  }

  /// Create a selling transaction and add it to the database.
  /// Then display a snackbar with a success message.
  void onSellClicked() async {
    if (double.parse(_coinController.text) > coinAmount) {
      displaySnackBar('You do not have enough ${widget.currency} to sell this amount.');
      return;
    } else {
      final crypto = await TransactionDatabase.instance.create(CryptoTransaction(
          currency: widget.currency,
          price: double.parse(widget.price),
          amount: double.parse(_coinController.text),
          date: DateTime.now(),
          type: TransactionType.sell));

      setState(() {
        coinAmount -= crypto.amount;
      });

      displaySnackBar('${crypto.amount} ${crypto.currency} sold');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coin Details"),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          child: Card(
            elevation: 2.7,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SwitchListTile(
                    title: Text(widget.currency, style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900)),
                    subtitle: Text("${widget.price}\$", style: const TextStyle(fontSize: 20.0)),
                    value: isBuyingState,
                    onChanged: ((value) {
                      setState(() => isBuyingState = value);
                    }),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Input field that has the amount of coin
                        SizedBox(
                          width: 230.0,
                          height: 55.0,
                          child: CustomTextField(
                            controller: _coinController,
                            onChanged: onCoinAmountChanged,
                            prefixIcon: const Icon(
                              Icons.currency_bitcoin,
                              color: Colors.yellow,
                            ),
                            borderText: 'Coin',
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: const Text(
                            "=",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Input field that has value of coin in dollars
                        SizedBox(
                          width: 230.0,
                          height: 55.0,
                          child: CustomTextField(
                            controller: _dollarController,
                            onChanged: onDollarAmountChanged,
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Colors.green,
                            ),
                            borderText: 'Dollar',
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isButtonDisabled
                        ? null
                        : isBuyingState
                            ? onAddToWalletClicked
                            : onSellClicked,
                    style: ButtonStyle(
                      backgroundColor: isButtonDisabled
                          ? null
                          : isBuyingState
                              ? MaterialStateProperty.all(Colors.blue)
                              : MaterialStateProperty.all(Colors.purple),
                    ),
                    child: Text(isBuyingState ? "BUY" : "SELL"),
                  ),
                  Text("You have ${coinAmount.toString()} ${widget.currency}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
