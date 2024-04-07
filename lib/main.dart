import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quotation.dart';
import 'stocks.dart';
import 'bitcoin.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Financeiro',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          fontFamily: GoogleFonts.inter().fontFamily),
      home: const MyHomePage(title: 'App Financeiro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: <Widget>[
        const Quotation(),
        const Bitcoin(),
        const Stocks(),
      ][_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.currency_exchange_outlined), label: 'Conversão'),
          NavigationDestination(icon: Icon(Icons.currency_bitcoin_outlined), label: 'Bitcoin'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Ações e taxas'),
        ],
      ),
    );
  }
}
