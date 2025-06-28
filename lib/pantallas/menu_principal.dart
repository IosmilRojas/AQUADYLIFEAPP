import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const verdeAquadylife = Color(0xFF43A047);
const celesteAquadylife = Color(0xFF4FC3F7);

String convertirEnlaceDriveADirecto(String url) {
  final regExp = RegExp(r'drive\.google\.com\/file\/d\/([^\/]+)');
  final match = regExp.firstMatch(url);
  if (match != null && match.groupCount >= 1) {
    final id = match.group(1);
    return 'https://drive.google.com/uc?export=view&id=$id';
  }
  // También soporta el formato corto de Google Drive
  final regExp2 = RegExp(r'd/([a-zA-Z0-9_-]+)');
  final match2 = regExp2.firstMatch(url);
  if (match2 != null) {
    final id = match2.group(1);
    return 'https://drive.google.com/uc?export=view&id=$id';
  }
  return url;
}

class MenuPrincipal extends StatelessWidget {
  Future<List<Map<String, dynamic>>> getTopFavoritos() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('BEBIDAS')
            .orderBy('valoracion', descending: true)
            .limit(5)
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTopVendidos() async {
    Map<String, int> ventasPorProducto = {};

    final ventasSnapshot =
        await FirebaseFirestore.instance.collection('VENTAS').get();
    for (var doc in ventasSnapshot.docs) {
      final data = doc.data();
      final productos = data['productos'] as List<dynamic>? ?? [];
      for (var producto in productos) {
        final codigo = producto['codigo'];
        final cantidad = producto['cantidad'] ?? 0;
        if (codigo != null) {
          ventasPorProducto[codigo] =
              (ventasPorProducto[codigo] ?? 0) + (cantidad as int);
        }
      }
    }

    final topCodigos =
        ventasPorProducto.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final top5Codigos = topCodigos.take(5).map((e) => e.key).toList();

    List<Map<String, dynamic>> topBebidas = [];
    for (String codigo in top5Codigos) {
      final bebidaSnapshot =
          await FirebaseFirestore.instance
              .collection('BEBIDAS') // CORREGIDO: debe ser mayúscula
              .where('codigo', isEqualTo: codigo)
              .limit(1)
              .get();
      if (bebidaSnapshot.docs.isNotEmpty) {
        final bebida = bebidaSnapshot.docs.first.data();
        bebida['ventas'] = ventasPorProducto[codigo];
        topBebidas.add(bebida);
      }
    }
    return topBebidas;
  }

  final List<Map<String, String>> sabiasQue = const [
    {
      'texto':
          'El agua constituye aproximadamente el 60% del peso corporal en adultos.',
      'icono': '💧',
    },
    {
      'texto':
          'Beber suficiente agua puede mejorar tu concentración y energía.',
      'icono': '⚡',
    },
    {
      'texto':
          'El agua ayuda a regular la temperatura corporal y eliminar toxinas.',
      'icono': '🌡️',
    },
    {
      'texto':
          'Tomar agua antes de las comidas puede ayudar a controlar el apetito.',
      'icono': '🥤',
    },
    {
      'texto':
          'La deshidratación leve puede causar dolores de cabeza y fatiga.',
      'icono': '🤕',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: celesteAquadylife.withOpacity(0.07),
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: verdeAquadylife,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.home, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: verdeAquadylife,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 54,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '¡Bienvenido a AQUADYLIFEAPP!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.water_drop,
                  color: celesteAquadylife,
                  size: 36,
                ),
                title: const Text(
                  'Consumo de agua hoy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('1.5 L / 2 L'),
                trailing: Icon(Icons.check_circle, color: verdeAquadylife),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar consumo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: celesteAquadylife,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Historial'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeAquadylife,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: celesteAquadylife.withOpacity(0.13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb, color: verdeAquadylife),
                        SizedBox(width: 8),
                        Text(
                          '¿Sabías que…?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: verdeAquadylife,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...sabiasQue.map(
                      (dato) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dato['icono']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dato['texto']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Top 5 productos favoritos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: verdeAquadylife,
                fontSize: 17,
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getTopFavoritos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final favoritos = snapshot.data!;
                return Column(
                  children:
                      favoritos.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var prod = entry.value;
                        int valoracion =
                            prod['valoracion'] is int
                                ? prod['valoracion']
                                : int.tryParse('${prod['valoracion']}') ?? 0;
                        valoracion = valoracion.clamp(0, 5);
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading:
                                prod['imagen'] != null &&
                                        prod['imagen'].toString().isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.network(
                                        convertirEnlaceDriveADirecto(
                                          prod['imagen'],
                                        ),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                ),
                                      ),
                                    )
                                    : CircleAvatar(
                                      backgroundColor: verdeAquadylife
                                          .withOpacity(0.2),
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          color: verdeAquadylife,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            title: Text(
                              prod['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: verdeAquadylife,
                              ),
                            ),
                            subtitle: Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  color:
                                      i < valoracion
                                          ? Colors.amber
                                          : Colors.grey[300],
                                  size: 18,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Top 5 productos más vendidos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: verdeAquadylife,
                fontSize: 17,
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getTopVendidos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final vendidos = snapshot.data!;
                return Column(
                  children:
                      vendidos.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var prod = entry.value;
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading:
                                prod['imagen'] != null &&
                                        prod['imagen'].toString().isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.network(
                                        convertirEnlaceDriveADirecto(
                                          prod['imagen'],
                                        ),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                ),
                                      ),
                                    )
                                    : CircleAvatar(
                                      backgroundColor: verdeAquadylife
                                          .withOpacity(0.2),
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          color: celesteAquadylife,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            title: Text(
                              prod['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: verdeAquadylife,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
