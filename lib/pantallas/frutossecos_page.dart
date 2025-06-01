import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FrutosSecosPage extends StatefulWidget {
  @override
  _FrutosSecosPageState createState() => _FrutosSecosPageState();
}

class _FrutosSecosPageState extends State<FrutosSecosPage> {
  final CollectionReference _frutosSecos = FirebaseFirestore.instance
      .collection('FRUTOS SECOS');

  final List<Map<String, dynamic>> _carrito = [];

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      _carrito.add(producto);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
    );
  }

  void _showAddDialog() {
    final _nombreController = TextEditingController();
    final _descripcionController = TextEditingController();
    final _imagenController = TextEditingController();
    final _stockController = TextEditingController();
    final _precioController = TextEditingController();
    final _codigoController = TextEditingController(
      text: 'FRUTO-${DateTime.now().millisecondsSinceEpoch}',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Fruto Seco'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // <-- Agrega esto
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
                await _frutosSecos.add({
                  'nombre': _nombreController.text,
                  'descripcion': _descripcionController.text,
                  'imagen': _imagenController.text,
                  'stock': int.tryParse(_stockController.text) ?? 0,
                  'precio': double.tryParse(_precioController.text) ?? 0,
                  'codigo': _codigoController.text,
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

  String convertirEnlaceDriveADirecto(String enlaceDrive) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frutos Secos'),
        actions: [
          // Carrito de compras
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
                        '${_carrito.length}',
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
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Carrito de Compras'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView(
                          shrinkWrap: true,
                          children:
                              _carrito
                                  .map(
                                    (producto) => ListTile(
                                      title: Text(producto['nombre'] ?? ''),
                                      subtitle: Text(
                                        'S/ ${producto['precio']?.toStringAsFixed(2) ?? '0.00'}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _carrito.clear();
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Vaciar carrito',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
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
        stream: _frutosSecos.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay frutos secos registrados.'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7, // Ajusta la altura para evitar overflow
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final urlImagenOriginal = data['imagen'] as String? ?? '';
              final urlImagenDirecta = convertirEnlaceDriveADirecto(
                urlImagenOriginal,
              );
              final double valoracion = (data['valoracion'] ?? 0).toDouble();

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                                        Icons.local_dining,
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
                            // --- Valoración (estrellas) aquí ---
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 2,
                              children: List.generate(5, (starIndex) {
                                final isFilled = starIndex < valoracion.round();
                                return GestureDetector(
                                  onTap: () async {
                                    await docs[index].reference.update({
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
                            // --- Precio debajo de la valoración ---
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
                            const SizedBox(height: 4),
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
}
