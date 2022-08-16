import 'dart:async';
import 'dart:convert';

import 'package:crypto_market/components/animated_card.dart';
import 'package:crypto_market/db/transaction_database.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/crypto_model.dart';

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) =>
      fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
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
  List<CryptoModel> liveCryptoData = [];
  late bool isDataLoaded;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isDataLoaded = false;
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      initSavedTransactions();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void initSavedTransactions() async {
    savedTransactions = await TransactionDatabase.instance.getTransactions();
    liveCryptoData = await fetchCrypto();

    setState(() {
      groupedTransactions = savedTransactions.groupBy((element) => element.currency);

      for (var list in groupedTransactions.values) {
        sumOfCurrencies = list
            .map((element) => element.type == TransactionType.buy
                ? double.parse(liveCryptoData.firstWhere((e) => e.currency == element.currency).price) * element.amount
                : double.parse(liveCryptoData.firstWhere((e) => e.currency == element.currency).price) * element.amount * -1)
            .reduce((previousValue, currentValue) => previousValue + currentValue);
      }

      isDataLoaded = true;
    });
  }

  Future<List<CryptoModel>> fetchCrypto() async {
    final response = await http.get(Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false&price_change_percentage=24h'));
    final List json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json.map((e) => CryptoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load crypto model');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Total value of coins: ${sumOfCurrencies.toStringAsFixed(3)}\$",
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            isDataLoaded
                ? Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        // My custom card for special use
                        return AnimatedCard(
                          transactionMap: groupedTransactions,
                          index: index,
                          liveData: liveCryptoData,
                        );
                      },
                      itemCount: groupedTransactions.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                    ),
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
