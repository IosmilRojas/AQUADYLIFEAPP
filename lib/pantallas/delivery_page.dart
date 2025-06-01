import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeliveryPage extends StatefulWidget {
  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final CollectionReference _pedidos =
      FirebaseFirestore.instance.collection('DELIVERY');

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _direccionController = TextEditingController();
  final _productoController = TextEditingController();
  final _cantidadController = TextEditingController();
  String _estado = 'Pendiente';
  String? _documentId;

  void _limpiarCampos() {
    _formKey.currentState?.reset();
    _clienteController.clear();
    _direccionController.clear();
    _productoController.clear();
    _cantidadController.clear();
    _estado = 'Pendiente';
    _documentId = null;
  }

  void _showAddOrEditDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _documentId = doc.id;
      _clienteController.text = data['cliente'] ?? '';
      _direccionController.text = data['direccion'] ?? '';
      _productoController.text = data['producto'] ?? '';
      _cantidadController.text = data['cantidad']?.toString() ?? '';
      _estado = data['estado'] ?? 'Pendiente';
    } else {
      _limpiarCampos();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(doc == null ? 'Nuevo Pedido' : 'Editar Pedido'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _clienteController,
                    decoration: const InputDecoration(labelText: 'Cliente'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    controller: _productoController,
                    decoration: const InputDecoration(labelText: 'Producto'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  TextFormField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obligatorio';
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Pendiente', child: Text('Pendiente')),
                      DropdownMenuItem(
                          value: 'En camino', child: Text('En camino')),
                      DropdownMenuItem(
                          value: 'Entregado', child: Text('Entregado')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _estado = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarCampos();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final pedido = {
                    'cliente': _clienteController.text.trim(),
                    'direccion': _direccionController.text.trim(),
                    'producto': _productoController.text.trim(),
                    'cantidad': int.tryParse(_cantidadController.text) ?? 1,
                    'estado': _estado,
                  };
                  if (_documentId == null) {
                    await _pedidos.add(pedido);
                  } else {
                    await _pedidos.doc(_documentId).update(pedido);
                  }
                  Navigator.of(context).pop();
                  _limpiarCampos();
                }
              },
              child: Text(doc == null ? 'Registrar' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarPedido(String id) {
    _pedidos.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo Pedido',
            onPressed: () => _showAddOrEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pedidos.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay pedidos registrados.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining, color: Colors.indigo),
                  title: Text(data['cliente'] ?? ''),
                  subtitle: Text(
                    'Dirección: ${data['direccion'] ?? ''}\n'
                    'Producto: ${data['producto'] ?? ''}\n'
                    'Cantidad: ${data['cantidad'] ?? ''}\n'
                    'Estado: ${data['estado'] ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _showAddOrEditDialog(doc: docs[index]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarPedido(docs[index].id),
                      ),
                    ],
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
