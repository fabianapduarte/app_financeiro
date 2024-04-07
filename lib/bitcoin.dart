import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?key=67dfdc00&fields=only_results,bitcoin&format=json-cors';

class Bitcoin extends StatefulWidget {
  const Bitcoin({super.key});

  @override
  State<Bitcoin> createState() => _BitcoinState();
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}

class _BitcoinState extends State<Bitcoin> {
  Map bitcoinData = {};

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
                bitcoinData = snapshot.data!['bitcoin'];

                return SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: getBitcoinCardList(context, bitcoinData),
                        )));
              }
          }
        }));
  }
}

List<Widget> getBitcoinCardList(BuildContext context, Map bitcoinData) {
  List<Widget> cardList = [];

  for (var key in bitcoinData.keys) {
    var bitcoin = bitcoinData[key];
    cardList.add(getCard(context, bitcoin));
  }

  return cardList;
}

Widget getCard(BuildContext context, dynamic bitcoin) {
  final String currency = bitcoin['format'][0];
  final String flag = currency == 'BRL' ? '🇧🇷' : '🇺🇸';
  final String last = bitcoin['last'].toStringAsFixed(2);

  return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card.filled(
          child: SizedBox(
              width: double.maxFinite,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(children: <Widget>[
                          Text(bitcoin['name'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              )),
                          Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(flag, style: GoogleFonts.notoColorEmoji()))
                        ])),
                    Row(children: <Widget>[
                      const Text('Preço:',
                          style: TextStyle(
                            fontSize: 16.0,
                          )),
                      Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text("$currency $last",
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)))
                    ]),
                  ])))));
}
