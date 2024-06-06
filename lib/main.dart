import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/blank_page.dart';
import './pages/home_page.dart';
// Asegúrate de importar correctamente BlankPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Gastos',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: HomePage(),
      routes: {
         '/home': (context) => HomePage(),
        '/blank': (context) => BlankPage(transactions: []),
      },
    );
  }
}
