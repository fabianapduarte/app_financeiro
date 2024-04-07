import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?format=json-cors&key=67dfdc00&fields=only_results,currencies';

class Quotation extends StatefulWidget {
  const Quotation({super.key});

  @override
  State<Quotation> createState() => _QuotationState();
}

Future<Map> getQuotation() async {
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}

Widget getInput(TextEditingController controller, String label, String prefix, Function function) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        onChanged: (value) => function(value),
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 16.0),
            border: const OutlineInputBorder(),
            prefixText: "$prefix "),
        style: const TextStyle(fontSize: 16.0),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ));
}

class _QuotationState extends State<Quotation> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final poundController = TextEditingController();
  final euroController = TextEditingController();

  double dolar = 0;
  double pound = 0;
  double euro = 0;

  void clearControllers() {
    realController.text = '';
    dolarController.text = '';
    poundController.text = '';
    euroController.text = '';
  }

  void _realConversion(String text) {
    if (text.isEmpty) {
      clearControllers();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    poundController.text = (real / pound).toStringAsFixed(2);
  }

  void _dolarConversion(String text) {
    if (text.isEmpty) {
      clearControllers();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    poundController.text = (dolar * this.dolar / pound).toStringAsFixed(2);
  }

  void _euroConversion(String text) {
    if (text.isEmpty) {
      clearControllers();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    poundController.text = (euro * this.euro / pound).toStringAsFixed(2);
  }

  void _poundConversion(String text) {
    if (text.isEmpty) {
      clearControllers();
      return;
    }

    double pound = double.parse(text);
    realController.text = (pound * this.pound).toStringAsFixed(2);
    euroController.text = (pound * this.pound / euro).toStringAsFixed(2);
    dolarController.text = (pound * this.pound / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getQuotation(),
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
                dolar = snapshot.data!["currencies"]["USD"]["buy"];
                euro = snapshot.data!["currencies"]["EUR"]["buy"];
                pound = snapshot.data!["currencies"]["GBP"]["buy"];

                return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getInput(realController, 'Real', 'R\$', _realConversion),
                        getInput(dolarController, 'Dólar', 'US\$', _dolarConversion),
                        getInput(euroController, 'Euro', '€', _euroConversion),
                        getInput(poundController, 'Libra esterlina', '£', _poundConversion),
                      ],
                    ));
              }
          }
        }));
  }
}
