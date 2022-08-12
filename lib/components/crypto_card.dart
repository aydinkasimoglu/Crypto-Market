import 'dart:ui';

import 'package:crypto_market/model/favorite_currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/crypto_model.dart';
import '../screens/coin_details_page.dart';

class CryptoCard extends StatefulWidget {
  const CryptoCard({Key? key, required this.crypto, required this.favOnPressed}) : super(key: key);

  final CryptoModel crypto;
  final void Function() favOnPressed;

  @override
  State<CryptoCard> createState() => _CryptoCardState();
}

class _CryptoCardState extends State<CryptoCard> {
  late bool isBlurAppeared;
  late Future<List<FavoriteCurrency>> futureFavoriteCurrencies;

  @override
  void initState() {
    super.initState();
    setState(() {
      isBlurAppeared = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          elevation: 1.5,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              isBlurAppeared
                  ? null
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CoinDetailsPage(
                                crypto: widget.crypto,
                              )));
            },
            onLongPress: () {
              setState(() {
                isBlurAppeared = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                title: Text(
                  widget.crypto.currency,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${double.parse(widget.crypto.price).toStringAsFixed(4)}\$",
                  style: const TextStyle(fontSize: 15.0),
                ),
                trailing: Text(
                  "${(double.parse(widget.crypto.priceChangePct) * 100).toStringAsFixed(3)}%",
                  style: TextStyle(
                      fontSize: 15.0, color: widget.crypto.priceChangePct.startsWith('-') ? Colors.red : Colors.green),
                ),
                leading: widget.crypto.logoUrl.endsWith('svg')
                    ? SvgPicture.network(
                        widget.crypto.logoUrl,
                        height: 40.0,
                        width: 40.0,
                      )
                    : Image.network(
                        widget.crypto.logoUrl,
                        height: 40.0,
                        width: 40.0,
                      ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: isBlurAppeared
                    ? ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: isBlurAppeared
                    ? Container(
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Adds the currency to the favorites list when pressed.
                            ElevatedButton.icon(
                                onPressed: () {
                                  widget.favOnPressed();
                                  setState(() {
                                    isBlurAppeared = false;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.purpleAccent),
                                ),
                                icon: const Icon(Icons.star),
                                label: const Text('Favorite')),
                            const SizedBox(width: 10.0),
                            // Closes blur effect when pressed.
                            ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isBlurAppeared = false;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(Colors.red),
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text('Close')),
                          ],
                        ),
                      )
                    : Container(
                        color: Colors.white.withOpacity(0.0),
                        child: const Text(''),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
