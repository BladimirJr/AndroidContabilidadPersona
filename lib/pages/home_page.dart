import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/blank_page.dart';
import '../models/transaction_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _transactionType = 'Gasto';
  String _category = 'Comida';
  DateTime _selectedDate = DateTime.now();
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  int _selectedIndex = 0;

  void _addTransaction() {
  double value = double.tryParse(_valueController.text) ?? 0.0;
  if (_transactionType == 'Entrada') {
    _balance += value;
  } else {
    _balance -= value;
  }

  setState(() {
    _transactions.add(Transaction(
      value: value,
      type: _transactionType,
      date: _selectedDate,
      category: _category,
      description: _descriptionController.text,
    ));
  });

  _valueController.clear();
  _descriptionController.clear();

  // Llamar a la función para guardar las transacciones
  saveTransactions(_transactions);
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetSaldo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Saldo'),
          content: Text('¿Desea eliminar definitivamente el saldo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _balance = 0.0;
                  _transactions.clear(); // Si deseas también reiniciar la lista de transacciones
                });

                Navigator.of(context).pop(); // Cierra el diálogo

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saldo reiniciado a \$0.00'),
                    backgroundColor: Colors.teal,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlankPage(transactions: _transactions),
      ),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Gastos'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _transactionType,
              onChanged: (String? newValue) {
                setState(() {
                  _transactionType = newValue!;
                });
              },
              items: <String>['Gasto', 'Entrada']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipo de Transacción',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue!;
                });
              },
              items: <String>['Comida', 'Bus', 'Bebidas', 'Hospedaje', 'Otros', 'Pago']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("${_selectedDate.toLocal()}".split(' ')[0]),
                SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Seleccionar fecha'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTransaction,
              child: Text('Agregar'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.teal,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Saldo: \$${_balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _resetSaldo,
              child: Text('Reiniciar Saldo'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.red,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(
                        transaction.type == 'Entrada'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.type == 'Entrada' ? Colors.green : Colors.red,
                      ),
                      title: Text('${transaction.category}: \$${transaction.value.toStringAsFixed(2)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${transaction.description}'),
                          Text('${transaction.date.toLocal()}'.split(' ')[0]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        selectedItemColor: Colors.teal,
      ),
    );
  }
}

