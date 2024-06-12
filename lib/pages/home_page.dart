import 'dart:io';
import 'package:flutter/material.dart';
import 'package:App_Contable/pages/blank_page.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initFile().then((_) {
      _loadBalance().then((_) {
        _loadTransactions();
      });
    });
  }

  Future<void> _loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getDouble('balance') ?? 0.0;
    });
  }

  Future<void> _saveBalance(double balance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', balance);

    if (balance == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saldo reiniciado a \$0.00'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // Registra el saldo reiniciado en el archivo de texto
      await _writeToFile('Saldo reiniciado a \$0.00');
    }
  }

  Future<void> _writeToFile(String data) async {
    if (_filePath.isEmpty) {
      await _initFile();
    }

    File file = File(_filePath);
    await file.writeAsString('$data\n', mode: FileMode.append);
  }

  Future<void> _initFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/transacciones.txt';
    File file = File(_filePath);

    // Crea el archivo si no existe
    if (!file.existsSync()) {
      file.createSync();
    }
  }

  Future<void> _loadTransactions() async {
    File file = File(_filePath);
    if (!file.existsSync()) {
      return;
    }
    List<String> lines = await file.readAsLines();
    setState(() {
      _transactions = lines
          .map((line) {
            List<String> parts = line.split(",");
            if (parts.length < 5) {
              // Línea no válida, omitir
              return null;
            }
            try {
              var value = double.parse(parts[0].trim());
              return Transaction(
                value: value,
                type: parts[1],
                date: DateTime.parse(parts[2]),
                category: parts[3],
                description: parts[4],
              );
            } catch (e) {
              // Manejar el error de formato
              print("Error de formato al leer el valor: $e");
              // Puedes retornar null o un valor predeterminado
              return null;
            }
          })
          .whereType<Transaction>()
          .toList();
    });
  }

  Future<void> _printFileContent() async {
    File file = File(_filePath);
    String fileContent = await file.readAsString();
    print('Contenido del archivo:');
    print(fileContent);
  }

  Future<void> _addTransaction() async {
    double value = double.tryParse(_valueController.text) ?? 0.0;
    if (_transactionType == 'Entrada') {
      _balance += value;
      _printFileContent();
    } else {
      _balance -= value;
    }

    final newTransaction = Transaction(
      value: value,
      type: _transactionType,
      date: _selectedDate,
      category: _category,
      description: _descriptionController.text,
    );

    setState(() {
      _transactions.add(newTransaction);
    });

    await guardarTransaccionEnArchivo(newTransaction);

    _valueController.clear();
    _descriptionController.clear();

    await _saveBalance(_balance);
  }

  Future<void> guardarTransaccionEnArchivo(Transaction transaccion) async {
    File file = File(_filePath);
    await file.writeAsString(
        "${transaccion.value},${transaccion.type},${transaccion.date},${transaccion.category},${transaccion.description}\n",
        mode: FileMode.append);
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

  Future<void> _resetSaldo() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Saldo'),
          content: Text(
              '¿Desea eliminar definitivamente el saldo y todas las transacciones?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _balance = 0.0;
                  _transactions.clear();
                });

                // Borrar las transacciones en el archivo
                File file = File(_filePath);
                if (file.existsSync()) {
                  await file
                      .writeAsString(''); // Limpiar el contenido del archivo
                }

                await _saveBalance(_balance);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saldo y transacciones reiniciados.'),
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
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: 'Valor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monetization_on),
              ),
              style: TextStyle(color: Colors.white),
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
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Color.fromARGB(255, 121, 119,
                            119)), // Cambiar el color del texto a blanco
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipo de Transacción',
                labelStyle: TextStyle(
                    color: Colors
                        .white), // Cambiar el color del texto de la etiqueta a blanco
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
              items: <String>[
                'Comida',
                'Bus',
                'Bebidas',
                'Hospedaje',
                'Otros',
                'Pago',
                'Didi Moto',
                'Recreacion',
                'Deudas'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Color.fromARGB(255, 124, 123,
                            123)), // Cambiar el color del texto a blanco
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: TextStyle(
                    color: Colors
                        .white), // Cambiar el color del texto de la etiqueta a blanco
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "${_selectedDate.toLocal()}".split(' ')[0],
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Seleccionar fecha'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: Text(
                    'Agregar',
                    style: TextStyle(
                        color:
                            Colors.black), // Cambiar el color del texto a blanco
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    backgroundColor: Colors.teal,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetSaldo,
                  child: Text('Reiniciar Saldo'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Saldo: \$${_balance.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 3.0),
                    child: ListTile(
                      leading: Icon(
                        transaction.type == 'Entrada'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.type == 'Entrada'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text(
                          '${transaction.category}: \$${transaction.value.toStringAsFixed(2)}'),
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
