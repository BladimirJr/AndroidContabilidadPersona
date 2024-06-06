import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Transaction {
  final double value;
  final String type;
  final DateTime date;
  final String category;
  final String description;

  Transaction({
    required this.value,
    required this.type,
    required this.date,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
    };
  }
}

void saveTransactions(List<Transaction> transactions) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/transactions.json');

  // Convertir la lista de transacciones a una lista de Map<String, dynamic>
  List<Map<String, dynamic>> transactionsJsonList = transactions.map((transaction) => transaction.toJson()).toList();

  // Convertir la lista de Map a un JSON String
  String transactionsJsonString = json.encode(transactionsJsonList);

  // Escribir el JSON String en el archivo
  await file.writeAsString(transactionsJsonString);
}
