import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BebidasPage extends StatefulWidget {
  const BebidasPage({Key? key}) : super(key: key);

  @override
  _BebidasPageState createState() => _BebidasPageState();
}

class _BebidasPageState extends State<BebidasPage> {
  final CollectionReference _bebidas = FirebaseFirestore.instance.collection(
    'BEBIDAS',
  );

  final List<Map<String, dynamic>> _carrito = [];

  String _searchTerm = ''; // Término de búsqueda
  bool _isSearching =
      false; // Para controlar si la barra de búsqueda está activa
  final TextEditingController _searchController =
      TextEditingController(); // Controlador para el TextField de búsqueda

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      text: 'BEBIDA-${DateTime.now().millisecondsSinceEpoch}',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Bebida'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  'category': 'General',
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
        title:
            _isSearching
                ? Container(
                  // Envolvemos el TextField en un Container para mejor control del diseño
                  height: 40, // Altura fija para el TextField
                  decoration: BoxDecoration(
                    color:
                        Colors.white, // Fondo blanco para que el texto se vea
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Bordes redondeados
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar bebidas...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ), // Color de hint más visible
                      border: InputBorder.none, // Quitamos el borde por defecto
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ), // Relleno para el texto
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ), // Icono de lupa dentro del campo
                      suffixIcon:
                          _searchTerm
                                  .isNotEmpty // Solo muestra la 'x' si hay texto
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchTerm = '';
                                  });
                                },
                              )
                              : null,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ), // Color de texto negro
                    cursorColor:
                        Theme.of(
                          context,
                        ).colorScheme.primary, // Color del cursor
                    autofocus: true,
                  ),
                )
                : const Text('Bebidas'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchTerm = '';
                }
              });
            },
            tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar',
          ),
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
                        child:
                            _carrito.isEmpty
                                ? const Center(
                                  child: Text('El carrito está vacío.'),
                                )
                                : ListView(
                                  shrinkWrap: true,
                                  children:
                                      _carrito
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) => ListTile(
                                              title: Text(
                                                entry.value['nombre'] ?? '',
                                              ),
                                              subtitle: Text(
                                                'S/ ${entry.value['precio']?.toStringAsFixed(2) ?? '0.00'}',
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _carrito.removeAt(
                                                      entry.key,
                                                    );
                                                  });
                                                  if (_carrito.isEmpty) {
                                                    Navigator.of(context).pop();
                                                  } else {
                                                    (context as Element)
                                                        .markNeedsBuild();
                                                  }
                                                },
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
        stream: _bebidas.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay bebidas registradas.'));
          }

          final allDocs = snapshot.data!.docs;
          final filteredDocs =
              allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final nombre = (data['nombre'] as String? ?? '').toLowerCase();
                final descripcion =
                    (data['descripcion'] as String? ?? '').toLowerCase();
                final searchTermLower = _searchTerm.toLowerCase();

                return _searchTerm.isEmpty ||
                    nombre.contains(searchTermLower) ||
                    descripcion.contains(searchTermLower);
              }).toList();

          if (filteredDocs.isEmpty && _searchTerm.isNotEmpty) {
            return Center(
              child: Text(
                'No se encontraron bebidas que coincidan con "$_searchTerm".',
              ),
            );
          } else if (filteredDocs.isEmpty) {
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
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
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
                                    (context) => Dialog(
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
}
