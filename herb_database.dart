import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock de Hierbas',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const MyHomePage(title: 'Stock de Hierbas'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aplicación de Gestión de Stock de Hierbas',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Center(
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _consultarRegistros(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Center(
                      child: const Text(
                        'Consultar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    // ... Código del cuadro de diálogo para ingresar hierbas
  }

  Future<void> _consultarRegistros(BuildContext context) async {
    // Obtener la lista de hierbas almacenadas en la base de datos
    List<Map<String, dynamic>> herbs = await HerbDatabase.instance.getHerbs();

    // Mostrar la lista de hierbas en la consola
    for (var herb in herbs) {
      print(
          'ID: ${herb['id']}, Nombre: ${herb['name']}, Lote: ${herb['lot']}, Vencimiento: ${herb['expiration']}, Cantidad: ${herb['quantity']}');
    }
  }
}

class HerbDatabase {
  static final HerbDatabase instance = HerbDatabase._init();

  static Database? _database;

  HerbDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('herb_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(
      join(await getDatabasesPath(), filePath),
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE herbs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, lot TEXT, expiration TEXT, quantity REAL)
    ''');
  }

  Future<void> insertHerb(Map<String, dynamic> herb) async {
    final db = await database;
    await db.insert('herbs', herb);
  }

  Future<List<Map<String, dynamic>>> getHerbs() async {
    final db = await database;
    return await db.query('herbs');
  }
}
