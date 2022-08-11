import 'dart:convert';

import 'package:crypto_market/components/crypto_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/crypto_model.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> with SingleTickerProviderStateMixin {
  late Future<List<CryptoModel>> futureCryptoModel;
  List<CryptoModel> filteredList = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    setState(() {
      futureCryptoModel = fetchCrypto();
      _tabController = TabController(length: 4, vsync: this);
    });
    initFilteredList();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void initFilteredList() async => filteredList = await futureCryptoModel;

  /// Fetch the crypto data from the API
  Future<List<CryptoModel>> fetchCrypto() async {
    final response = await http.get(Uri.parse(
        'https://api.nomics.com/v1/currencies/ticker?key=b6352825d16d34d26e59f897facc320a11bcd630&interval=1d&status=active&per-page=100&page=1'));
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
          Container(
            height: 35.0,
            margin: const EdgeInsets.only(bottom: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.green,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              tabs: const <Tab>[
                Tab(
                  text: "All",
                ),
                Tab(
                  text: "Favorites",
                ),
                Tab(
                  text: "Top Gainers",
                ),
                Tab(
                  text: "Top Losers",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    // Text field to filter the list view by the name of crypto currencies
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 15.0),
                      child: SizedBox(
                        width: 300.0,
                        height: 55.0,
                        child: TextField(
                          onChanged: (value) => runFilter(value),
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Filter'),
                        ),
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

                                      return CryptoCard(crypto: crypto);
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
                const Center(
                  child: Text("Favorites"),
                ),
                const Center(
                  child: Text("Top Gainers"),
                ),
                const Center(
                  child: Text("Top Losers"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
