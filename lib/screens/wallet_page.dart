import 'package:crypto_market/db/transaction_database.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double sumOfCurrencies = 0.0;
  List<CryptoTransaction> savedTransactions = [];
  Map<String, List<CryptoTransaction>> groupedTransactions = {};
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    initSavedTransactions();
  }

  void initSavedTransactions() async {
    savedTransactions = await TransactionDatabase.instance.getTransactions();
    for (var element in savedTransactions) {
      sumOfCurrencies += element.amount * element.price;
    }

    setState(() {
      groupedTransactions =
          savedTransactions.groupBy((element) => element.currency);
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
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: AnimatedSize(
                          curve: Curves.easeIn,
                          duration: const Duration(seconds: 1),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    groupedTransactions.keys.elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(groupedTransactions.values
                                      .elementAt(index)
                                      .map((element) => element.amount)
                                      .reduce((previousValue, currentValue) =>
                                          previousValue + currentValue)
                                      .toString()),
                                ],
                              ),
                              isExpanded ? const Divider() : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: groupedTransactions.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
