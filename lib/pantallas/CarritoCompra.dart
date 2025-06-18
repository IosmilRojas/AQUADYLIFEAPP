import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoCompraPage extends StatefulWidget {
  final String userId;
  final String nombreUsuario;
  final String apellidosUsuario;
  final String correoUsuario;
  final List<Map<String, dynamic>> productosCarrito;

  const CarritoCompraPage({
    Key? key,
    required this.userId,
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

  double get _total => widget.productosCarrito.fold(
    0.0,
    (sum, item) => sum + (item['precio'] as num) * (item['cantidad'] as num),
  );

  Future<void> _registrarVenta() async {
    if (widget.productosCarrito.isEmpty) return;

    final venta = {
      'usuarioId': widget.userId,
      'nombreUsuario': widget.nombreUsuario,
      'apellidosUsuario': widget.apellidosUsuario,
      'correoUsuario': widget.correoUsuario,
      'productos': widget.productosCarrito,
      'total': _total,
      'metodoPago': _metodoPago,
      'fecha': Timestamp.now(),
      'estado': 'pendiente',
    };

    await FirebaseFirestore.instance.collection('VENTAS').add(venta);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra registrada exitosamente!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.productosCarrito.length,
                itemBuilder: (context, index) {
                  final producto = widget.productosCarrito[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          producto['imagen'] != null &&
                                  (producto['imagen'] as String).isNotEmpty
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
                                          ),
                                ),
                              )
                              : Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.local_drink, size: 40),
                              ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  producto['nombre'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Cantidad: ${producto['cantidad']}'),
                                const SizedBox(height: 4),
                                Text('S/ ${producto['precio']}'),
                              ],
                            ),
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
                const Text('Método de pago:'),
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
                const Text('Total:', style: TextStyle(fontSize: 18)),
                Text(
                  'S/ ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text('Confirmar compra'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _registrarVenta,
            ),
          ],
        ),
      ),
    );
  }
}
