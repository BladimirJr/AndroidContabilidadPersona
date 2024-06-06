import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class BlankPage extends StatelessWidget {
  final List<Transaction> transactions;

  // Constructor que acepta una lista de transacciones
  BlankPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Procesar los datos de transacciones para calcular el total por categoría
    Map<String, double> categoryTotals = {};
    transactions.forEach((transaction) {
      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.value,
        ifAbsent: () => transaction.value,
      );
    });

    // Crear widgets de barras para cada categoría
    List<Widget> bars = [];
    categoryTotals.forEach((category, total) {
      bars.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              SizedBox(width: 100, child: Text(category)),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 20,
                  color: Colors.teal,
                  width: total * 5, // Escala arbitraria para la visualización
                ),
              ),
              SizedBox(width: 10),
              Text('\$${total.toStringAsFixed(2)}'),
            ],
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Transacciones'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: bars,
        ),
      ),
    );
  }
}
