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
  late TabController _tabController;
  List<CryptoModel> filteredList = [];

  final StreamController<List<CryptoModel>> _cryptoModelController = StreamController<List<CryptoModel>>.broadcast();
  final StreamController<List<FavoriteCurrency>> _favCurrencyController = StreamController<List<FavoriteCurrency>>.broadcast();
  Stream<List<CryptoModel>> _cryptoModelStream = const Stream<List<CryptoModel>>.empty();
  Stream<List<FavoriteCurrency>> _favCurrencyStream = const Stream<List<FavoriteCurrency>>.empty();
  List<CryptoModel> cryptoModelStreamData = [];
  List<FavoriteCurrency> favCryptoStreamData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _cryptoModelStream = _cryptoModelController.stream;
    _favCurrencyStream = _favCurrencyController.stream;

    _cryptoModelStream.listen((data) {
      setState(() {
        cryptoModelStreamData = data;
      });
    });

    _favCurrencyStream.listen((data) {
      setState(() {
        favCryptoStreamData = data;
      });
    });

    Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      final res = await fetchCrypto();
      _cryptoModelController.add(res);
      fetchFavCurrency();
    });

    initFilteredList();
  }

  void initFilteredList() async => filteredList = await fetchCrypto();

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

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

  void fetchFavCurrency() async {
    debugPrint("fetchFavCurrency() called");
    _favCurrencyController.add(await FavoritesDatabase.instance.getCurrencies());
  }

  /// Filter the list of crypto models by the given search query.
  void runFilter(String filter) {
    List<CryptoModel> results = [];

    if (filter.isEmpty) {
      results = cryptoModelStreamData;
    } else {
      results =
          cryptoModelStreamData.where((element) => element.currency.toLowerCase().startsWith(filter.toLowerCase())).toList();
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
                    StreamBuilder<List<CryptoModel>>(
                      stream: _cryptoModelStream,
                      builder: (BuildContext context, AsyncSnapshot<List<CryptoModel>> snapshot) {
                        if (snapshot.hasData) {
                          return Expanded(
                            child: filteredList.isNotEmpty
                                ? ListView.separated(
                                    itemBuilder: (BuildContext context, int index) {
                                      /// Check if the crypto currency is in the list of favorites.
                                      /// If it is, mension that it is already in favorites. Otherwise, add currency to favorites.
                                      void addToFavorites() async {
                                        final favCurrencies = await FavoritesDatabase.instance.getCurrencies();
                                        for (var element in favCurrencies) {
                                          if (element.currency == filteredList[index].currency) {
                                            displaySnackBar('Already in favorites');
                                            return;
                                          }
                                        }
                                        final fav = await FavoritesDatabase.instance.create(FavoriteCurrency(
                                          currency: filteredList[index].currency,
                                        ));

                                        fetchFavCurrency();

                                        displaySnackBar("${fav.currency} added to favorites");
                                      }

                                      return CryptoCard(
                                        crypto: filteredList[index],
                                        favOnPressed: addToFavorites,
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5.0),
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
                StreamBuilder<List<FavoriteCurrency>>(
                  stream: _favCurrencyStream,
                  builder: (BuildContext context, AsyncSnapshot<List<FavoriteCurrency>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          final favCrypto = (snapshot.data as List<FavoriteCurrency>)[index];
                          debugPrint("CryptoStreamData: $cryptoModelStreamData");

                          final favCryptoPrice =
                              cryptoModelStreamData.firstWhere((element) => element.currency == favCrypto.currency).price;
                          final favCryptoChange = cryptoModelStreamData
                              .firstWhere((element) => element.currency == favCrypto.currency)
                              .priceChangePct;
                          final favCryptoLogo =
                              cryptoModelStreamData.firstWhere((element) => element.currency == favCrypto.currency).logoUrl;

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
                                          fontSize: 15.0, color: favCryptoChange.startsWith('-') ? Colors.red : Colors.green),
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
                                    fetchFavCurrency();
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
                        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5.0),
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
