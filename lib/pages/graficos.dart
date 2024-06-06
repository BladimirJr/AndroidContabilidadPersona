import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_application_2/models/transaction_model.dart';

class ChartPage extends StatelessWidget {
  final List<Transaction> transactions;

  ChartPage({required this.transactions});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Transaction, String>> series = [
      charts.Series(
        id: 'Transactions',
        data: transactions,
        domainFn: (Transaction transaction, _) => transaction.category,
        measureFn: (Transaction transaction, _) => transaction.value,
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Transacciones'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: charts.BarChart(series, animate: true),
      ),
    );
  }
}
