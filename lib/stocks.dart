import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?key=67dfdc00&format=json-cors';

class Stocks extends StatefulWidget {
  const Stocks({super.key});

  @override
  State<Stocks> createState() => _StocksState();
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}

class _StocksState extends State<Stocks> {
  Map stocks = {};
  Map taxes = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getData(),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: Text(
                  'Carregando...',
                  style: TextStyle(fontSize: 16.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Erro ao carregar dados",
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ));
              } else {
                stocks = snapshot.data!['results']["stocks"];
                taxes = snapshot.data!['results']['taxes'][0];

                return SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(bottom: 10.0, left: 8.0),
                                child: Text('Taxas', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: getTaxesCardList(context, taxes),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 40.0, bottom: 10.0, left: 8.0),
                                child: Text('Ações', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)))
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getStocksCardList(context, stocks),
                        )
                      ])),
                );
              }
          }
        }));
  }
}

List<Widget> getTaxesCardList(BuildContext context, Map taxes) {
  List<Widget> cardList = [];

  for (var key in taxes.keys) {
    if (key == 'cdi' || key == 'selic') {
      var tax = taxes[key];
      cardList.add(getTaxCard(context, key, tax));
    }
  }

  return cardList;
}

Widget getTaxCard(BuildContext context, String key, double tax) {
  return Card.filled(
      child: SizedBox(
          width: (MediaQuery.sizeOf(context).width / 2) - 32.0,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(tax.toStringAsFixed(2),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 35.0,
                              fontWeight: FontWeight.w900,
                              fontVariations: const <FontVariation>[FontVariation('wght', 900.0)])))
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16.0,
                      ))
                ])
              ]))));
}

List<Widget> getStocksCardList(BuildContext context, Map stocks) {
  List<Widget> cardList = [];

  for (var key in stocks.keys) {
    var stock = stocks[key];
    cardList.add(getCard(context, key, stock['name'], stock['location'], stock['points']));
  }

  return cardList;
}

Widget getCard(BuildContext context, String acronym, String name, String location, double points) {
  return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card.filled(
          child: SizedBox(
              width: double.maxFinite,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(acronym,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              )))
                    ]),
                    Row(children: <Widget>[getKeyText('Nome'), getValueText(name)]),
                    Row(children: <Widget>[getKeyText('Localização'), getValueText(location)]),
                    Row(children: <Widget>[getKeyText('Pontos'), getValueText(points.toString())])
                  ])))));
}

Text getKeyText(String key) {
  return Text('$key:',
      style: const TextStyle(
        fontSize: 16.0,
      ));
}

Expanded getValueText(String value) {
  return Expanded(
      child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(value,
              style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 16.0, fontWeight: FontWeight.w600))));
}
