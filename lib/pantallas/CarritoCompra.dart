import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoCompraPage extends StatefulWidget {
  final String userId;
  final List<Map<String, dynamic>>
  productosCarrito; // [{nombre, precio, cantidad, ...}]

  const CarritoCompraPage({
    Key? key,
    required this.userId,
    required this.productosCarrito,
  }) : super(key: key);

  @override
  State<CarritoCompraPage> createState() => _CarritoCompraPageState();
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
      'productos': widget.productosCarrito,
      'total': _total,
      'metodoPago': _metodoPago,
      'fecha': Timestamp.now(),
      'estado': 'pendiente', // o 'pagado', según tu lógica
    };

    await FirebaseFirestore.instance.collection('VENTAS').add(venta);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra registrada exitosamente!')),
    );

    Navigator.of(context).pop(); // Regresa a la pantalla anterior
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
                  return ListTile(
                    leading:
                        producto['imagen'] != null &&
                                (producto['imagen'] as String).isNotEmpty
                            ? CircleAvatar(
                              backgroundImage: NetworkImage(producto['imagen']),
                              radius: 24,
                              backgroundColor: Colors.grey[200],
                            )
                            : const CircleAvatar(
                              child: Icon(Icons.local_drink),
                              backgroundColor: Colors.grey,
                            ),
                    title: Text(producto['nombre']),
                    subtitle: Text('Cantidad: ${producto['cantidad']}'),
                    trailing: Text('S/ ${producto['precio']}'),
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
