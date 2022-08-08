import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/crypto_model.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key, required this.savedCurrencies}) : super(key: key);

  final Map<String, double> savedCurrencies;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double sumOfCurrencies = 0.0;
  late Map<String, double> savedCurrencies;

  @override
  void initState() {
    super.initState();
    savedCurrencies = widget.savedCurrencies;
    loadSavedCurrencies();
  }

  Future<void> loadSavedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();

    final hashMapString = prefs.getString('currencies') ?? '{}';
    setState(() {
      savedCurrencies = Map<String, double>.from(jsonDecode(hashMapString));
      savedCurrencies.forEach((key, value) {sumOfCurrencies += value * double.parse(CryptoModel.fromJson(jsonDecode(key)).price);});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Text("${sumOfCurrencies.toStringAsFixed(3)}\$", style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),

            ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          CryptoModel.fromJson(jsonDecode(savedCurrencies.entries.elementAt(index).key)).currency,
                          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                        ),
                        Text(savedCurrencies.entries.elementAt(index).value.toString())
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
