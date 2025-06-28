import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  String? _editingId;

  void _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(_precioController.text) ?? 0.0;
    if (nombre.isEmpty) return;
    final ref = FirebaseFirestore.instance.collection('productos');
    if (_editingId == null) {
      await ref.add({'nombre': nombre, 'precio': precio});
    } else {
      await ref.doc(_editingId).update({'nombre': nombre, 'precio': precio});
    }
    _nombreController.clear();
    _precioController.clear();
    _editingId = null;
    setState(() {});
  }

  void _editarProducto(Map<String, dynamic> data, String id) {
    _nombreController.text = data['nombre'];
    _precioController.text = data['precio'].toString();
    _editingId = id;
    setState(() {});
  }

  void _eliminarProducto(String id) async {
    await FirebaseFirestore.instance.collection('productos').doc(id).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(title: const Text("Panel de Administración")),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(title: 'Inicio', icon: Icons.home, route: '/'),
        ],
        selectedRoute: '/',
        onSelected: (item) {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _guardarProducto,
              child: Text(_editingId == null ? 'Agregar' : 'Actualizar'),
            ),
          ]),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Precio')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DataRow(cells: [
                        DataCell(Text(data['nombre'] ?? '')),
                        DataCell(Text('S/ ${data['precio']}')),
                        DataCell(Row(children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editarProducto(data, doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarProducto(doc.id),
                          ),
                        ])),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}