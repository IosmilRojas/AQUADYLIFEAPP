import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoCompraPage extends StatefulWidget {
  final String dniUsuario;
  final String nombreUsuario;
  final String apellidosUsuario;
  final String correoUsuario;
  final List<Map<String, dynamic>> productosCarrito;

  const CarritoCompraPage({
    Key? key,
    required this.dniUsuario,
    required this.nombreUsuario,
    required this.apellidosUsuario,
    required this.correoUsuario,
    required this.productosCarrito,
  }) : super(key: key);

  @override
  State<CarritoCompraPage> createState() => _CarritoCompraPageState();
}

String convertirEnlaceDriveADirecto(String url) {
  final regExp = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)');
  final match = regExp.firstMatch(url);
  if (match != null && match.groupCount >= 1) {
    final id = match.group(1);
    return 'https://drive.google.com/uc?export=view&id=$id';
  }
  return url;
}

class _CarritoCompraPageState extends State<CarritoCompraPage> {
  String _metodoPago = 'Efectivo';
  late List<Map<String, dynamic>> _carrito;

  @override
  void initState() {
    super.initState();
    // Copia el carrito para poder modificarlo localmente
    _carrito =
        widget.productosCarrito
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
  }

  double get _total => _carrito.fold(
    0.0,
    (sum, item) => sum + (item['precio'] as num) * (item['cantidad'] as num),
  );

  Future<void> _registrarVenta() async {
    if (_carrito.isEmpty) return;

    final venta = {
      'dniUsuario': widget.dniUsuario,
      'nombreUsuario': widget.nombreUsuario,
      'apellidosUsuario': widget.apellidosUsuario,
      'correoUsuario': widget.correoUsuario,
      'productos': _carrito,
      'total': _total,
      'metodoPago': _metodoPago,
      'fecha': Timestamp.now(),
      'estado': 'finalizado',
    };

    await FirebaseFirestore.instance.collection('VENTAS').add(venta);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra registrada exitosamente!')),
    );

    setState(() {
      _carrito.clear(); // Limpiar el carrito local
    });

    // Espera un frame para que el usuario vea el carrito vacío antes de cerrar
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(
        context,
      ).pop(true); // Devuelve true para limpiar el carrito global
    }
  }

  void _eliminarProducto(int index) {
    setState(() {
      _carrito.removeAt(index);
      if (_carrito.isEmpty) {
        // Si el carrito queda vacío, cerrar y devolver la lista vacía
        Navigator.of(context).pop(_carrito);
      }
    });
  }

  void _cambiarCantidad(int index, int nuevaCantidad) {
    if (nuevaCantidad < 1) return;
    setState(() {
      _carrito[index]['cantidad'] = nuevaCantidad;
    });
  }

  @override
  Widget build(BuildContext context) {
    const verdeAquadylife = Color(0xFF43A047);
    const celesteAquadylife = Color(0xFF4FC3F7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: verdeAquadylife,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _carrito.isEmpty
                      ? const Center(child: Text('El carrito está vacío.'))
                      : ListView.builder(
                        itemCount: _carrito.length,
                        itemBuilder: (context, index) {
                          final producto = _carrito[index];
                          return Card(
                            color: celesteAquadylife.withOpacity(0.08),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  producto['imagen'] != null &&
                                          (producto['imagen'] as String)
                                              .isNotEmpty
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          convertirEnlaceDriveADirecto(
                                            producto['imagen'],
                                          ),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 70,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      )
                                      : Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.local_drink,
                                          size: 40,
                                          color: verdeAquadylife,
                                        ),
                                      ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto['nombre'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: verdeAquadylife,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: verdeAquadylife,
                                              ),
                                              onPressed: () {
                                                if (producto['cantidad'] > 1) {
                                                  _cambiarCantidad(
                                                    index,
                                                    producto['cantidad'] - 1,
                                                  );
                                                }
                                              },
                                            ),
                                            Text(
                                              'Cantidad: ${producto['cantidad']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: verdeAquadylife,
                                              ),
                                              onPressed: () {
                                                _cambiarCantidad(
                                                  index,
                                                  producto['cantidad'] + 1,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'S/ ${producto['precio']}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _eliminarProducto(index),
                                    tooltip: 'Eliminar producto',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Método de pago:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _metodoPago,
                  items: const [
                    DropdownMenuItem(
                      value: 'Efectivo',
                      child: Text('Efectivo'),
                    ),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(
                      value: 'Yape/Plin',
                      child: Text('Yape/Plin'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _metodoPago = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'S/ ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Confirmar compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeAquadylife,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _registrarVenta,
            ),
          ],
        ),
      ),
    );
  }
}
