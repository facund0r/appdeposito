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

  Future<Map<String, dynamic>?> getHerbByName(String name) async {
    final db = await database;
    List<Map<String, dynamic>> result =
        await db.query('herbs', where: 'name = ?', whereArgs: [name]);

    return result.isNotEmpty ? result.first : null;
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
                    _showTodasLasHerbasDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors
                        .red, // Puedes ajustar el color según tu preferencia
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Container(
                    width: 200,
                    child: Center(
                      child: const Text(
                        'Todas las Hierbas',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  onPressed: () async {
                    await _consultarRegistros(context);
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showModificarDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.purple,
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
                        'Modificar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showDescontarDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
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
                        'Descontar',
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

  Future<void> _showTodasLasHerbasDialog(BuildContext context) async {
    List<Map<String, dynamic>> hierbas = await HerbDatabase.instance.getHerbs();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Todas las Hierbas'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: hierbas.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    _mostrarDetallesHerba(context, hierbas[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      hierbas[index]['name'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDetallesHerba(
      BuildContext context, Map<String, dynamic> herba) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de ${herba['name']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nombre: ${herba['name']}',
                    style: TextStyle(fontSize: 18)),
                Text('Lote: ${herba['lot']}', style: TextStyle(fontSize: 18)),
                Text('Vencimiento: ${herba['expiration']}',
                    style: TextStyle(fontSize: 18)),
                Text('Cantidad: ${herba['quantity']} kg',
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _mostrarIngresarCantidadDialog(context, herba);
                      },
                      child: Text('Ingresar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _mostrarDescontarCantidadDialog(context, herba);
                      },
                      child: Text('Descontar'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _mostrarModificarHerbaDialog(context, herba);
                  },
                  child: Text('Modificar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarIngresarCantidadDialog(
      BuildContext context, Map<String, dynamic> herba) async {
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingresar más cantidad'),
          content: Column(
            children: [
              Text('Nombre: ${herba['name']}', style: TextStyle(fontSize: 18)),
              Text('Lote: ${herba['lot']}', style: TextStyle(fontSize: 18)),
              Text('Vencimiento: ${herba['expiration']}',
                  style: TextStyle(fontSize: 18)),
              Text('Cantidad actual: ${herba['quantity']} kg',
                  style: TextStyle(fontSize: 18)),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                    labelText: 'Nueva cantidad a ingresar (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                double cantidadAIngresar =
                    double.parse(quantityController.text);

                if (cantidadAIngresar > 0) {
                  await _actualizarCantidadHerba(herba, cantidadAIngresar);
                  Navigator.of(context).popUntil(
                      (route) => route.isFirst); // Cerrar todas las ventanas

                  // Actualizar la información de la hierba después de ingresar la cantidad
                  await _actualizarInformacionHerba(context, herba['name']);

                  // Volver al menú principal de todas las hierbas
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage(title: 'Stock de Hierbas')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, ingresa una cantidad válida.'),
                    ),
                  );
                }
              },
              child: Text('Ingresar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actualizarInformacionHerba(
      BuildContext context, String nombreHerba) async {
    Map<String, dynamic>? herb =
        await HerbDatabase.instance.getHerbByName(nombreHerba);

    if (herb != null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Información de la Hierba'),
            content: Column(
              children: [
                Text('Nombre: ${herb['name']}', style: TextStyle(fontSize: 18)),
                Text('Lote: ${herb['lot']}', style: TextStyle(fontSize: 18)),
                Text('Vencimiento: ${herb['expiration']}',
                    style: TextStyle(fontSize: 18)),
                Text('Cantidad: ${herb['quantity']} kg',
                    style: TextStyle(fontSize: 18)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el cuadro de diálogo
                },
                child: Text('Atrás'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se encontró la hierba con el nombre proporcionado.',
          ),
        ),
      );
    }
  }

  Future<void> _actualizarCantidadHerba(
      Map<String, dynamic> herba, double cantidadAIngresar) async {
    // Actualizar la cantidad en la base de datos
    double nuevaCantidad = herba['quantity'] + cantidadAIngresar;
    await HerbDatabase.instance.database.then((db) {
      return db.update(
        'herbs',
        {'quantity': nuevaCantidad},
        where: 'id = ?',
        whereArgs: [herba['id']],
      );
    });
  }

  Future<void> _mostrarDescontarCantidadDialog(
      BuildContext context, Map<String, dynamic> herba) async {
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Descontar cantidad'),
          content: Column(
            children: [
              Text('Nombre: ${herba['name']}', style: TextStyle(fontSize: 18)),
              Text('Lote: ${herba['lot']}', style: TextStyle(fontSize: 18)),
              Text('Vencimiento: ${herba['expiration']}',
                  style: TextStyle(fontSize: 18)),
              Text('Cantidad actual: ${herba['quantity']} kg',
                  style: TextStyle(fontSize: 18)),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                    labelText: 'Nueva cantidad a descontar (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                double cantidadADescontar =
                    double.parse(quantityController.text);

                if (cantidadADescontar > 0 &&
                    cantidadADescontar <= herba['quantity']) {
                  await _actualizarCantidadHerba(herba, -cantidadADescontar);
                  Navigator.of(context).popUntil(
                      (route) => route.isFirst); // Cerrar todas las ventanas

                  // Mostrar la información actualizada de la hierba
                  await _actualizarInformacionHerba(context, herba['name']);

                  // Volver al menú principal de todas las hierbas
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage(title: 'Stock de Hierbas')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La cantidad a descontar no es válida.'),
                    ),
                  );
                }
              },
              child: Text('Descontar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarModificarHerbaDialog(
      BuildContext context, Map<String, dynamic> herb) async {
    // Implementa la lógica para modificar hierba aquí
    TextEditingController lotController =
        TextEditingController(text: herb['lot']);
    TextEditingController expirationController =
        TextEditingController(text: herb['expiration']);
    TextEditingController quantityController =
        TextEditingController(text: herb['quantity'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Hierba'),
          content: Column(
            children: [
              TextField(
                controller: lotController,
                decoration: InputDecoration(labelText: 'Lote'),
              ),
              TextField(
                controller: expirationController,
                decoration: InputDecoration(labelText: 'Vencimiento'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Cantidad en kg'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Actualizar la información en la base de datos
                await HerbDatabase.instance.database.then((db) {
                  return db.update(
                    'herbs',
                    {
                      'lot': lotController.text,
                      'expiration': expirationController.text,
                      'quantity': double.parse(quantityController.text),
                    },
                    where: 'id = ?',
                    whereArgs: [herb['id']],
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Información de la hierba modificada exitosamente.'),
                  ),
                );

                // Cerrar el cuadro de diálogo y volver al menú principal de todas las hierbas
                Navigator.of(context).popUntil((route) => route.isFirst);

                // Actualizar la información de la hierba después de la modificación
                await _actualizarInformacionHerba(context, herb['name']);
              },
              child: Text('Modificar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showHerbDetailsDialog(
      BuildContext context, Map<String, dynamic> herb) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de ${herb['name']}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nombre: ${herb['name']}', style: TextStyle(fontSize: 18)),
              Text('Lote: ${herb['lot']}', style: TextStyle(fontSize: 18)),
              Text('Vencimiento: ${herb['expiration']}',
                  style: TextStyle(fontSize: 18)),
              Text('Cantidad: ${herb['quantity']} kg',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController lotController = TextEditingController();
    TextEditingController expirationController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Gestionar Hierba'),
          content: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Nuevo producto
                        Navigator.pop(context);

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Ingresar Nueva Hierba'),
                              content: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                        labelText: 'Nombre de la Hierba'),
                                  ),
                                  TextField(
                                    controller: lotController,
                                    decoration:
                                        InputDecoration(labelText: 'Lote'),
                                  ),
                                  TextField(
                                    controller: expirationController,
                                    decoration: InputDecoration(
                                        labelText: 'Vencimiento'),
                                  ),
                                  TextField(
                                    controller: quantityController,
                                    decoration: InputDecoration(
                                        labelText: 'Cantidad en kg'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    // Verificar si la hierba ya existe
                                    Map<String, dynamic>? existingHerb =
                                        await HerbDatabase.instance
                                            .getHerbByName(nameController.text);

                                    if (existingHerb != null) {
                                      // La hierba ya existe
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'La hierba ya existe. No se ha ingresado una nueva.'),
                                        ),
                                      );
                                    } else {
                                      // La hierba no existe, ingresarlo
                                      await HerbDatabase.instance.insertHerb({
                                        'name': nameController.text,
                                        'lot': lotController.text,
                                        'expiration': expirationController.text,
                                        'quantity': double.parse(
                                            quantityController.text),
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Nueva hierba ingresada exitosamente.'),
                                        ),
                                      );
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: Text('Ingresar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancelar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Center(
                          child: const Text(
                            'Ingresar Nueva Hierba',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Consultar hierba por nombre
                        TextEditingController nameController =
                            TextEditingController();

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Ingresar Más Cantidad'),
                              content: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nombre de la Hierba',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Map<String, dynamic>? herb =
                                        await HerbDatabase.instance
                                            .getHerbByName(nameController.text);

                                    if (herb != null) {
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);

                                      // Mostrar información existente
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Información de la Hierba'),
                                            content: Column(
                                              children: [
                                                Text('Nombre: ${herb['name']}',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                Text('Lote: ${herb['lot']}',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                Text(
                                                    'Vencimiento: ${herb['expiration']}',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                Text(
                                                    'Cantidad: ${herb['quantity']} kg',
                                                    style: TextStyle(
                                                        fontSize: 18)),
                                                SizedBox(height: 16),
                                                // Contenedor para ingresar nueva cantidad
                                                TextField(
                                                  controller:
                                                      quantityController,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Nueva cantidad a ingresar (kg)',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  double quantityToAdd =
                                                      double.parse(
                                                          quantityController
                                                              .text);

                                                  // Actualizar la cantidad en la base de datos
                                                  await HerbDatabase
                                                      .instance.database
                                                      .then((db) {
                                                    return db.update(
                                                      'herbs',
                                                      {
                                                        'quantity':
                                                            herb['quantity'] +
                                                                quantityToAdd,
                                                      },
                                                      where: 'id = ?',
                                                      whereArgs: [herb['id']],
                                                    );
                                                  });

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Cantidad actualizada exitosamente.'),
                                                    ),
                                                  );

                                                  // Cerrar el cuadro de diálogo y volver al menú principal
                                                  Navigator.pop(
                                                      context); // Cerrar el cuadro de diálogo
                                                },
                                                child: Text('Ingresar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancelar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'No se encontró la hierba con el nombre proporcionado.',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(
                                          context); // Cerrar el cuadro de diálogo
                                    }
                                  },
                                  child: Text('Consultar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancelar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Center(
                          child: const Text(
                            'Ingresar Más Cantidad',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _consultarRegistros(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Consultar Hierba'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Hierba'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Map<String, dynamic>? herb = await HerbDatabase.instance
                    .getHerbByName(nameController.text);

                if (herb != null) {
                  Navigator.pop(context);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Información de la Hierba'),
                        content: Column(
                          children: [
                            Text('Nombre: ${herb['name']}',
                                style: TextStyle(fontSize: 18)),
                            Text('Lote: ${herb['lot']}',
                                style: TextStyle(fontSize: 18)),
                            Text('Vencimiento: ${herb['expiration']}',
                                style: TextStyle(fontSize: 18)),
                            Text('Cantidad: ${herb['quantity']} kg',
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Atrás'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'No se encontró la hierba con el nombre proporcionado.'),
                    ),
                  );
                }
              },
              child: Text('Consultar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showModificarDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Hierba'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Hierba'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String herbName = nameController.text.trim();
                if (herbName.isNotEmpty) {
                  // Consultar hierba por nombre
                  Map<String, dynamic>? herb =
                      await HerbDatabase.instance.getHerbByName(herbName);

                  if (herb != null) {
                    Navigator.pop(context);

                    // Mostrar información existente
                    await _showModificarInfoDialog(context, herb);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No se encontró la hierba con el nombre proporcionado.',
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, ingresa un nombre de hierba.'),
                    ),
                  );
                }
              },
              child: Text('Modificar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showModificarInfoDialog(
      BuildContext context, Map<String, dynamic> herb) async {
    TextEditingController lotController =
        TextEditingController(text: herb['lot']);
    TextEditingController expirationController =
        TextEditingController(text: herb['expiration']);
    TextEditingController quantityController =
        TextEditingController(text: herb['quantity'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modificar Hierba'),
          content: Column(
            children: [
              TextField(
                controller: lotController,
                decoration: InputDecoration(labelText: 'Lote'),
              ),
              TextField(
                controller: expirationController,
                decoration: InputDecoration(labelText: 'Vencimiento'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Cantidad en kg'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Actualizar la información en la base de datos
                await HerbDatabase.instance.database.then((db) {
                  return db.update(
                    'herbs',
                    {
                      'lot': lotController.text,
                      'expiration': expirationController.text,
                      'quantity': double.parse(quantityController.text),
                    },
                    where: 'id = ?',
                    whereArgs: [herb['id']],
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Información de la hierba modificada exitosamente.',
                    ),
                  ),
                );

                // Cerrar el cuadro de diálogo y volver al menú principal
                Navigator.pop(context);
              },
              child: Text('Modificar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDescontarDialog(BuildContext context) async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Descontar Hierba'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Hierba'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Map<String, dynamic>? herb = await HerbDatabase.instance
                    .getHerbByName(nameController.text);

                if (herb != null) {
                  Navigator.pop(context);

                  await _showDescontarCantidadDialog(context, herb);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'No se encontró la hierba con el nombre proporcionado.'),
                    ),
                  );
                }
              },
              child: Text('Consultar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDescontarCantidadDialog(
      BuildContext context, Map<String, dynamic> herb) async {
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Descontar Hierba'),
          content: Column(
            children: [
              Text('Nombre: ${herb['name']}', style: TextStyle(fontSize: 18)),
              Text('Lote: ${herb['lot']}', style: TextStyle(fontSize: 18)),
              Text('Vencimiento: ${herb['expiration']}',
                  style: TextStyle(fontSize: 18)),
              Text('Cantidad actual: ${herb['quantity']} kg',
                  style: TextStyle(fontSize: 18)),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                    labelText: 'Nueva cantidad a descontar (kg)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                double quantityToDescontar =
                    double.parse(quantityController.text);

                if (herb['quantity'] >= quantityToDescontar) {
                  // Actualizar la cantidad en la base de datos
                  await HerbDatabase.instance.database.then((db) {
                    return db.update(
                      'herbs',
                      {
                        'quantity': herb['quantity'] - quantityToDescontar,
                      },
                      where: 'id = ?',
                      whereArgs: [herb['id']],
                    );
                  });

                  Navigator.pop(context);

                  // Actualizar la pantalla principal con la información más reciente
                  await _consultarRegistros(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'La cantidad a descontar es mayor que la cantidad actual.'),
                    ),
                  );
                }
              },
              child: Text('Descontar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
