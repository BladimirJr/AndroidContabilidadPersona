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

