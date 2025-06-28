import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorialPedidosScreen extends StatelessWidget {
  final String userEmail;
  final String userName;

  const HistorialPedidosScreen({
    Key? key,
    required this.userEmail,
    required this.userName,
  }) : super(key: key);

  void _mostrarDetalleCompra(
    BuildContext context,
    Map<String, dynamic> compra,
  ) {
    final productos = compra['productos'] as List<dynamic>;
    final fecha = (compra['fecha'] as Timestamp).toDate();
    const verdeAquadylife = Color(0xFF43A047);
    const celesteAquadylife = Color(0xFF4FC3F7);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Row(
              children: [
                Icon(Icons.receipt_long, color: celesteAquadylife),
                const SizedBox(width: 8),
                Text(
                  'Detalle de la compra',
                  style: TextStyle(
                    color: verdeAquadylife,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: verdeAquadylife,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        size: 18,
                        color: celesteAquadylife,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Método: ${compra['metodoPago']}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 18,
                        color: celesteAquadylife,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Estado: ${compra['estado'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: celesteAquadylife),
                  const Text(
                    'Productos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: verdeAquadylife,
                    ),
                  ),
                  ...productos.map(
                    (p) => ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.local_drink,
                        color: celesteAquadylife,
                      ),
                      title: Text(
                        p['nombre'] ?? '',
                        style: const TextStyle(color: verdeAquadylife),
                      ),
                      subtitle: Text(
                        'Cantidad: ${p['cantidad']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Text(
                        'S/ ${p['precio']}',
                        style: const TextStyle(
                          color: Colors.black, // Mejor contraste
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: celesteAquadylife),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total: S/ ${compra['total'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Mejor contraste
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: celesteAquadylife),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const verdeAquadylife = Color(0xFF43A047);
    const celesteAquadylife = Color(0xFF4FC3F7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: verdeAquadylife,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('VENTAS')
                .where('correoUsuario', isEqualTo: userEmail)
                .orderBy('fecha', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: celesteAquadylife.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No tienes compras registradas.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }
          final compras = snapshot.data!.docs;
          return ListView.builder(
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final compra = compras[index];
              final productos = compra['productos'] as List<dynamic>;
              final fecha = (compra['fecha'] as Timestamp).toDate();
              return Card(
                color: celesteAquadylife.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: verdeAquadylife.withOpacity(0.18),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF43A047),
                    ),
                  ),
                  title: Text(
                    'Total: S/ ${compra['total'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black, // Mejor contraste
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pago: ${compra['metodoPago']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: verdeAquadylife.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      ...productos
                          .take(2)
                          .map(
                            (p) => Text(
                              '${p['nombre']} x${p['cantidad']} - S/ ${p['precio']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black, // Mejor contraste
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      if (productos.length > 2)
                        Text(
                          '+${productos.length - 2} productos más',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: celesteAquadylife,
                    size: 20,
                  ),
                  onTap:
                      () => _mostrarDetalleCompra(
                        context,
                        compra.data() as Map<String, dynamic>,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
