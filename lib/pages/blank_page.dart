import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class BlankPage extends StatefulWidget {
  final List<Transaction> transactions;

  BlankPage({required this.transactions});

  @override
  _BlankPageState createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  Map<String, bool> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    // Procesar los datos de transacciones para calcular el total por categoría
    Map<String, double> categoryTotals = {};
    Map<String, List<Transaction>> categoryTransactions = {};
    
    widget.transactions.forEach((transaction) {
      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.value,
        ifAbsent: () => transaction.value,
      );
      
      if (!categoryTransactions.containsKey(transaction.category)) {
        categoryTransactions[transaction.category] = [];
      }
      categoryTransactions[transaction.category]!.add(transaction);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Transacciones'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Cambia este color al que desees para el fondo
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: categoryTotals.keys.map((category) {
            double total = categoryTotals[category]!;
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      category,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.teal),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _expandedCategories[category] ?? false
                          ? Icons.expand_less
                          : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _expandedCategories[category] = !(_expandedCategories[category] ?? false);
                        });
                      },
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _expandedCategories[category] ?? false ? null : 0,
                    child: Column(
                      children: categoryTransactions[category]!.map((transaction) {
                        return ListTile(
                          title: Text(
                            '${transaction.description} - \$${transaction.value.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            '${transaction.date.toLocal()}'.split(' ')[0],
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
