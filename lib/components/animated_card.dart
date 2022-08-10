import 'package:crypto_market/model/crypto_transaction.dart';
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({Key? key, required this.map, required this.index})
      : super(key: key);

  final Map<String, List<CryptoTransaction>> map;
  final int index;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.easeInOut,
      duration: const Duration(seconds: 1),
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
            debugPrint(isExpanded.toString());
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.map.keys.elementAt(widget.index),
                      style: const TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w500),
                    ),
                    Text(widget.map.values
                        .elementAt(widget.index)
                        .map((element) => element.amount)
                        .reduce((previousValue, currentValue) =>
                            previousValue + currentValue)
                        .toString()),
                  ],
                ),
                isExpanded
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Divider(),
                          ListView.builder(
                            itemBuilder: (ctxt, i) {
                              final buyOrSell = widget.map.values
                                          .elementAt(widget.index)
                                          .elementAt(i)
                                          .type ==
                                      TransactionType.buy
                                  ? '+'
                                  : '-';
                              final date = widget.map.values
                                  .elementAt(widget.index)
                                  .elementAt(i)
                                  .date;

                              return ListTile(
                                title: Text(
                                  widget.map.values
                                      .elementAt(widget.index)
                                      .elementAt(i)
                                      .currency,
                                  style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  "${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute}:${date.second}",
                                  style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                trailing: Text(
                                  "$buyOrSell${widget.map.values.elementAt(widget.index).elementAt(i).amount}",
                                  style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            },
                            itemCount: widget.map.values
                                .elementAt(widget.index)
                                .length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                          )
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
