import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CarritoCompra.dart';

class BebidasPage extends StatefulWidget {
  @override
  _BebidasPageState createState() => _BebidasPageState();
}

class _BebidasPageState extends State<BebidasPage> {
  final CollectionReference _bebidas = FirebaseFirestore.instance.collection(
    'BEBIDAS',
  );

  // El carrito ahora es un mapa para manejar cantidades
  final Map<String, Map<String, dynamic>> _carrito = {};

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      final codigo = producto['codigo'];
      if (_carrito.containsKey(codigo)) {
        _carrito[codigo]!['cantidad'] += 1;
      } else {
        _carrito[codigo] = Map<String, dynamic>.from(producto);
        _carrito[codigo]!['cantidad'] = 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bebidas'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_carrito.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${_carrito.values.fold<int>(0, (sum, item) => sum + (item['cantidad'] as int))}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CarritoCompraPage(
                        userId:
                            '', // TODO: Reemplaza con el userId real del usuario logueado
                        nombreUsuario:
                            '', // TODO: Reemplaza con el nombre real del usuario logueado
                        apellidosUsuario:
                            '', // TODO: Reemplaza con los apellidos reales del usuario logueado
                        correoUsuario:
                            '', // TODO: Reemplaza con el correo real del usuario logueado
                        productosCarrito:
                            _carrito.values
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList(),
                      ),
                ),
              );
            },
            tooltip: 'Ver carrito',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
            tooltip: 'Agregar más',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bebidas.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay bebidas registradas.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final urlImagenOriginal = data['imagen'] as String? ?? '';
              final urlImagenDirecta = convertirEnlaceDriveADirecto(
                urlImagenOriginal,
              );
              final double valoracion = (data['valoracion'] ?? 0).toDouble();

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 8,
                          right: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (urlImagenOriginal.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => Dialog(
                                      backgroundColor: Colors.black,
                                      insetPadding: const EdgeInsets.all(10),
                                      child: InteractiveViewer(
                                        child: Image.network(
                                          urlImagenDirecta,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                              );
                            }
                          },
                          child: AspectRatio(
                            aspectRatio: 1,
                            child:
                                urlImagenOriginal.isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        urlImagenDirecta,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    )
                                    : const Center(
                                      child: Icon(
                                        Icons.local_drink,
                                        size: 36,
                                        color: Colors.grey,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              data['nombre'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((data['descripcion'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: Text(
                                  data['descripcion'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 2,
                              children: List.generate(5, (starIndex) {
                                final isFilled = starIndex < valoracion.round();
                                return GestureDetector(
                                  onTap: () async {
                                    await doc.reference.update({
                                      'valoracion': starIndex + 1,
                                    });
                                    setState(() {});
                                  },
                                  child: Icon(
                                    isFilled ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                );
                              }),
                            ),
                            Text(
                              'S/ ${data['precio']?.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _agregarAlCarrito(data),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 13,
                                ),
                                label: const Text(
                                  'Agregar',
                                  style: TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(22),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog() {
    final _nombreController = TextEditingController();
    final _descripcionController = TextEditingController();
    final _imagenController = TextEditingController();
    final _stockController = TextEditingController();
    final _precioController = TextEditingController();
    final _codigoController = TextEditingController(
      text: 'BEBIDA-${DateTime.now().millisecondsSinceEpoch}',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Bebida'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _imagenController,
                  decoration: const InputDecoration(labelText: 'URL de Imagen'),
                ),
                TextField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _codigoController,
                  decoration: const InputDecoration(labelText: 'Código'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nombreController.text.isEmpty ||
                    _descripcionController.text.isEmpty ||
                    _imagenController.text.isEmpty ||
                    _stockController.text.isEmpty ||
                    _precioController.text.isEmpty ||
                    _codigoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }
                await _bebidas.add({
                  'nombre': _nombreController.text,
                  'descripcion': _descripcionController.text,
                  'imagen': _imagenController.text,
                  'stock': int.tryParse(_stockController.text) ?? 0,
                  'precio': double.tryParse(_precioController.text) ?? 0,
                  'codigo': _codigoController.text,
                  'valoracion': 0,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

// Utilidad para convertir enlaces de Google Drive
String convertirEnlaceDriveADirecto(String enlaceDrive) {
  final regExpD = RegExp(r'/d/([a-zA-Z0-9_-]+)');
  final regExpId = RegExp(r'id=([a-zA-Z0-9_-]+)');
  String? id;
  final matchD = regExpD.firstMatch(enlaceDrive);
  if (matchD != null && matchD.groupCount >= 1) {
    id = matchD.group(1);
  } else {
    final matchId = regExpId.firstMatch(enlaceDrive);
    if (matchId != null && matchId.groupCount >= 1) {
      id = matchId.group(1);
    }
  }
  if (id != null) {
    return 'https://drive.google.com/uc?export=view&id=$id';
  } else {
    return enlaceDrive;
  }
}
