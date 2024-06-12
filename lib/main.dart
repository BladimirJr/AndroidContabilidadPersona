import 'package:flutter/material.dart';
import './pages/home_page.dart';
import './pages/blank_page.dart';
import './pages/configuracion_page.dart'; 

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
        //'/configuracion': (context) => ConfiguracionPage(),
      },
    );
  }
}
