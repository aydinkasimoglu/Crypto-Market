import 'package:crypto_market/db/transaction_database.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double sumOfCurrencies = 0.0;
  late List<CryptoTransaction> savedCurrencies;

  @override
  void initState() {
    super.initState();
    setState(() async {
      savedCurrencies =
          await TransactionDatabase.instance.getTransactionsGroupedByCurrency();
      for (var element in savedCurrencies) {
        sumOfCurrencies += element.amount * element.price;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "${sumOfCurrencies.toStringAsFixed(3)}\$",
              style:
                  const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          savedCurrencies.elementAt(index).currency,
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w500),
                        ),
                        Text(
                            savedCurrencies.elementAt(index).amount.toString()),
                      ],
                    ),
                  ),
                );
              },
              itemCount: savedCurrencies.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
