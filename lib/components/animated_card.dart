import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({Key? key, required this.map, required this.index}) : super(key: key);

  final Map<String, List<CryptoTransaction>> map;
  final int index;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  late bool isExpanded;
  double coinAmount = 0.0;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
    setState(() {
      coinAmount = widget.map.values
          .elementAt(widget.index)
          .map((e) => e.type == TransactionType.buy ? e.amount : -e.amount)
          .reduce((a, b) => a + b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return coinAmount != 0.0
        ? AnimatedSize(
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 1),
            child: Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.map.keys.elementAt(widget.index),
                            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                          ),
                          Text(coinAmount.toString()),
                        ],
                      ),
                      isExpanded
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Divider(),
                                ListView.builder(
                                  itemBuilder: (ctxt, i) {
                                    // Using reversed order because we want to show the latest transactions first

                                    final buyOrSell =
                                        widget.map.values.elementAt(widget.index).reversed.elementAt(i).type ==
                                                TransactionType.buy
                                            ? '+'
                                            : '-';
                                    final date = widget.map.values.elementAt(widget.index).reversed.elementAt(i).date;

                                    return ListTile(
                                      title: Text(
                                        widget.map.values.elementAt(widget.index).reversed.elementAt(i).currency,
                                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        "${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}:${date.second}\n${widget.map.values.elementAt(widget.index).reversed.elementAt(i).price}\$",
                                        style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
                                      ),
                                      trailing: Text(
                                        "$buyOrSell${widget.map.values.elementAt(widget.index).reversed.elementAt(i).amount}",
                                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  },
                                  itemCount: widget.map.values.elementAt(widget.index).reversed.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
