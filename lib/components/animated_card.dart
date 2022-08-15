import 'package:crypto_market/model/crypto_model.dart';
import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({Key? key, required this.transactionMap, required this.index, required this.liveData}) : super(key: key);

  final Map<String, List<CryptoTransaction>> transactionMap;
  final int index;
  final List<CryptoModel> liveData;

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
      coinAmount = widget.transactionMap.values
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
                          Row(
                            children: <Widget>[
                              Image.network(
                                widget.liveData
                                    .firstWhere(
                                        (element) => element.currency == widget.transactionMap.keys.elementAt(widget.index))
                                    .logoUrl,
                                height: 28.0,
                                width: 28.0,
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                widget.transactionMap.keys.elementAt(widget.index).toUpperCase(),
                                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                              ),
                            ],
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
                                        widget.transactionMap.values.elementAt(widget.index).reversed.elementAt(i).type ==
                                                TransactionType.buy
                                            ? '+'
                                            : '-';
                                    final date = widget.transactionMap.values.elementAt(widget.index).reversed.elementAt(i).date;

                                    return ListTile(
                                      title: Text(
                                        widget.transactionMap.values
                                            .elementAt(widget.index)
                                            .reversed
                                            .elementAt(i)
                                            .currency
                                            .toUpperCase(),
                                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        "${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}:${date.second}\n${widget.transactionMap.values.elementAt(widget.index).reversed.elementAt(i).price}\$",
                                        style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
                                      ),
                                      trailing: Text(
                                        "$buyOrSell${widget.transactionMap.values.elementAt(widget.index).reversed.elementAt(i).amount}",
                                        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  },
                                  itemCount: widget.transactionMap.values.elementAt(widget.index).reversed.length,
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
