import 'package:crypto_market/db/transaction_database.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

import '../components/custom_text_field.dart';

class CoinDetailsPage extends StatefulWidget {
  const CoinDetailsPage({Key? key, required this.currency, required this.price})
      : super(key: key);

  final String currency;
  final String price;

  @override
  State<CoinDetailsPage> createState() => _CoinDetailsPageState();
}

class _CoinDetailsPageState extends State<CoinDetailsPage> {
  late TextEditingController _coinController;
  late TextEditingController _dollarController;
  bool isAddToWalletButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    _coinController = TextEditingController();
    _dollarController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _coinController.dispose();
    _dollarController.dispose();
  }

  void onCoinAmountChanged(String value) {
    try {
      if (value.isEmpty) {
        setState(() {
          isAddToWalletButtonDisabled = true;
        });
      } else if (double.parse(value) == 0.0) {
        setState(() {
          isAddToWalletButtonDisabled = true;
        });
      } else {
        setState(() {
          isAddToWalletButtonDisabled = false;
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
          isAddToWalletButtonDisabled = true;
        });
      } else if (double.parse(value) == 0.0) {
        setState(() {
          isAddToWalletButtonDisabled = true;
        });
      } else {
        setState(() {
          isAddToWalletButtonDisabled = false;
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

  /// Create a transaction and add it to the database.
  /// Then display a snackbar with a success message.
  Future<void> onAddToWalletClicked() async {
    final crypto = await TransactionDatabase.instance.create(CryptoTransaction(
        currency: widget.currency,
        price: double.parse(widget.price),
        amount: double.parse(_coinController.text),
        date: DateTime.now(),
        type: TransactionType.buy));

    displaySnackBar('${crypto.amount} ${crypto.currency} added to wallet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coin Details"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Big bold header that displays coin's name
            Text(
              widget.currency,
              style:
                  const TextStyle(fontSize: 45.0, fontWeight: FontWeight.w900),
            ),
            // Smaller text displays coin's price
            Text(
              "${widget.price}\$",
              style: const TextStyle(fontSize: 25.0),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Input field that has the amount of coin
                  SizedBox(
                    width: 150.0,
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Input field that has value of coin in dollars
                  SizedBox(
                    width: 150.0,
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
                onPressed:
                    isAddToWalletButtonDisabled ? null : onAddToWalletClicked,
                child: const Text("ADD TO WALLET"))
          ],
        ),
      ),
    );
  }
}
