import 'dart:async';
import 'dart:convert';

import 'package:crypto_market/components/crypto_card.dart';
import 'package:crypto_market/model/favorite_currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../db/favorites_database.dart';
import '../model/crypto_model.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({Key? key}) : super(key: key);

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> with SingleTickerProviderStateMixin {
  late Future<List<CryptoModel>> futureCryptoModel = fetchCrypto();
  late Future<List<FavoriteCurrency>> futureFavoriteCurrencies = fetchFavCurrency();
  List<CryptoModel> filteredList = [];
  List<CryptoModel> liveData = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    init();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void init() async {
    filteredList = await futureCryptoModel;
    liveData = await futureCryptoModel;
    Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        futureCryptoModel = fetchCrypto();
        futureFavoriteCurrencies = fetchFavCurrency();
      });
    });
  }

  /// Fetch the crypto data from the API
  Future<List<CryptoModel>> fetchCrypto() async {
    debugPrint("fetchCrypto() called");
    final response = await http.get(Uri.parse(
        'https://api.nomics.com/v1/currencies/ticker?key=b6352825d16d34d26e59f897facc320a11bcd630&interval=1d&status=active&page=1'));
    final List json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json.map((e) => CryptoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load crypto model');
    }
  }

  Future<List<FavoriteCurrency>> fetchFavCurrency() async {
    debugPrint("fetchFavCurrency() called");
    return await FavoritesDatabase.instance.getCurrencies();
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

  void displaySnackBar(String text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

                                      void addToFavorites() async {
                                        final favCurrencies = await FavoritesDatabase.instance.getCurrencies();
                                        for (var element in favCurrencies) {
                                          if (element.currency == crypto.currency) {
                                            displaySnackBar('Already in favorites');
                                            return;
                                          }
                                        }
                                        final fav = await FavoritesDatabase.instance.create(FavoriteCurrency(
                                          currency: crypto.currency,
                                        ));

                                        setState(() {
                                          futureFavoriteCurrencies = fetchFavCurrency();
                                        });

                                        displaySnackBar("${fav.currency} added to favorites");
                                      }

                                      return CryptoCard(
                                        crypto: crypto,
                                        favOnPressed: addToFavorites,
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
                FutureBuilder(
                  future: futureFavoriteCurrencies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          final favCrypto = (snapshot.data as List<FavoriteCurrency>)[index];

                          final favCryptoPrice =
                              liveData.firstWhere((element) => element.currency == favCrypto.currency).price;
                          final favCryptoChange =
                              liveData.firstWhere((element) => element.currency == favCrypto.currency).priceChangePct;
                          final favCryptoLogo =
                              liveData.firstWhere((element) => element.currency == favCrypto.currency).logoUrl;

                          return Card(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      favCrypto.currency,
                                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${double.parse(favCryptoPrice).toStringAsFixed(4)}\$",
                                      style: const TextStyle(fontSize: 15.0),
                                    ),
                                    trailing: Text(
                                      "${(double.parse(favCryptoChange) * 100).toStringAsFixed(3)}%",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          color: favCryptoChange.startsWith('-') ? Colors.red : Colors.green),
                                    ),
                                    leading: favCryptoLogo.endsWith('svg')
                                        ? SvgPicture.network(
                                            favCryptoLogo,
                                            height: 40.0,
                                            width: 40.0,
                                          )
                                        : Image.network(
                                            favCryptoLogo,
                                            height: 40.0,
                                            width: 40.0,
                                          ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    FavoritesDatabase.instance.delete(favCrypto.id!);
                                    setState(() {
                                      futureFavoriteCurrencies = fetchFavCurrency();
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(const CircleBorder()),
                                    backgroundColor: MaterialStateProperty.all(Colors.red),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 5.0),
                        itemCount: (snapshot.data as List<FavoriteCurrency>).length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return const CircularProgressIndicator();
                  },
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
