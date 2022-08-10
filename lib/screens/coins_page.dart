import 'dart:convert';

import 'package:crypto_market/screens/coin_details_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/crypto_model.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  late Future<List<CryptoModel>> futureCryptoModel;
  List<CryptoModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    futureCryptoModel = fetchCrypto();
    initFilteredList();
  }

  void initFilteredList() async => filteredList = await futureCryptoModel;

  /// Fetch the crypto data from the API
  Future<List<CryptoModel>> fetchCrypto() async {
    final response = await http
        .get(Uri.parse('https://raw.githubusercontent.com/atilsamancioglu/K21-JSONDataSet/master/crypto.json'));
    final List json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json.map((e) => CryptoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load crypto model');
    }
  }

  /// Filter the list of crypto models by the given search query.
  void runFilter(String filter) async {
    List<CryptoModel> results = [];

    if (filter.isEmpty) {
      results = await futureCryptoModel;
    } else {
      results = (await futureCryptoModel)
          .where((element) => element.currency.toLowerCase().startsWith(filter.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredList = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          // Text field to filter the list view by the name of crypto currencies
          Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            child: TextField(
              onChanged: (value) => runFilter(value),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Filter'),
            ),
          ),
          // The list of crypto currencies
          // Filled with the data came from web service
          FutureBuilder<List<CryptoModel>>(
            future: futureCryptoModel,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: filteredList.isNotEmpty
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            final crypto = filteredList[index];

                            return Card(
                              elevation: 1.5,
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CoinDetailsPage(currency: crypto.currency, price: crypto.price)));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        crypto.currency,
                                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "${crypto.price}\$",
                                        style: const TextStyle(fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 5.0),
                          itemCount: filteredList.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                        )
                      : const Text("No result"),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
