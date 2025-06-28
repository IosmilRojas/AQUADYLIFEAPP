import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

class TodosLosSensoresScreen extends StatefulWidget {
  const TodosLosSensoresScreen({super.key});

  @override
  State<TodosLosSensoresScreen> createState() => _TodosLosSensoresScreenState();
}

class _TodosLosSensoresScreenState extends State<TodosLosSensoresScreen> {
  String acelerometro = '', giroscopio = '', magnetometro = '', userAccel = '';
  bool _estaEnMovimiento = false;

  // Variables para almacenar temporalmente los datos
  double _accX = 0, _accY = 0, _accZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  double _magX = 0, _magY = 0, _magZ = 0;
  double _userAccX = 0, _userAccY = 0, _userAccZ = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    SensorsPlatform.instance.accelerometerEventStream().listen((e) {
      _accX = e.x;
      _accY = e.y;
      _accZ = e.z;
      _estaEnMovimiento =
          (_accX.abs() > 2 || _accY.abs() > 2 || _accZ.abs() > 2);
    });
    SensorsPlatform.instance.gyroscopeEventStream().listen((e) {
      _gyroX = e.x;
      _gyroY = e.y;
      _gyroZ = e.z;
    });
    SensorsPlatform.instance.magnetometerEventStream().listen((e) {
      _magX = e.x;
      _magY = e.y;
      _magZ = e.z;
    });
    SensorsPlatform.instance.userAccelerometerEventStream().listen((e) {
      _userAccX = e.x;
      _userAccY = e.y;
      _userAccZ = e.z;
    });

    // Actualiza la UI solo cada 200 ms
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        acelerometro =
            'X: ${_accX.toStringAsFixed(2)}\nY: ${_accY.toStringAsFixed(2)}\nZ: ${_accZ.toStringAsFixed(2)}';
        giroscopio =
            'X: ${_gyroX.toStringAsFixed(2)}\nY: ${_gyroY.toStringAsFixed(2)}\nZ: ${_gyroZ.toStringAsFixed(2)}';
        magnetometro =
            'X: ${_magX.toStringAsFixed(2)}\nY: ${_magY.toStringAsFixed(2)}\nZ: ${_magZ.toStringAsFixed(2)}';
        userAccel =
            'X: ${_userAccX.toStringAsFixed(2)}\nY: ${_userAccY.toStringAsFixed(2)}\nZ: ${_userAccZ.toStringAsFixed(2)}';
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verdeAquadylife = const Color(0xFF43A047);
    final celesteAquadylife = const Color(0xFF4FC3F7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensores del Móvil'),
        backgroundColor: verdeAquadylife,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Copiar datos',
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final datos =
                  'Acelerómetro:\n$acelerometro\n\n'
                  'Giroscopio:\n$giroscopio\n\n'
                  'Magnetómetro:\n$magnetometro\n\n'
                  'User Accel:\n$userAccel';
              await Clipboard.setData(ClipboardData(text: datos));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos copiados al portapapeles')),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            color:
                _estaEnMovimiento
                    ? Colors.orange.withOpacity(0.15)
                    : verdeAquadylife.withOpacity(0.07),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(
                _estaEnMovimiento
                    ? Icons.directions_run
                    : Icons.self_improvement,
                color: _estaEnMovimiento ? Colors.orange : verdeAquadylife,
                size: 36,
              ),
              title: Text(
                _estaEnMovimiento
                    ? '¡El dispositivo está en movimiento!'
                    : 'El dispositivo está en reposo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _estaEnMovimiento ? Colors.orange : verdeAquadylife,
                ),
              ),
              subtitle: Text(
                _estaEnMovimiento
                    ? '¡Cuidado! El movimiento puede afectar la precisión de algunas funciones.'
                    : 'No se detecta movimiento fuerte. Ideal para mediciones precisas.',
                style: const TextStyle(color: Colors.black87),
              ),
              trailing:
                  _estaEnMovimiento
                      ? const Icon(Icons.warning, color: Colors.orange)
                      : const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 18),
          _SensorCard(
            icon: Icons.directions_run,
            color: verdeAquadylife,
            title: 'Acelerómetro',
            description: 'Detecta movimientos lineales del teléfono.',
            value: acelerometro,
          ),
          _SensorCard(
            icon: Icons.screen_rotation,
            color: verdeAquadylife,
            title: 'Giroscopio',
            description: 'Detecta rotaciones y giros del dispositivo.',
            value: giroscopio,
          ),
          _SensorCard(
            icon: Icons.explore,
            color: verdeAquadylife,
            title: 'Magnetómetro',
            description: 'Detecta campos magnéticos (brújula).',
            value: magnetometro,
          ),
          _SensorCard(
            icon: Icons.directions_walk,
            color: verdeAquadylife,
            title: 'User Accelerometer',
            description: 'Detecta movimientos del usuario (sin gravedad).',
            value: userAccel,
          ),
          const SizedBox(height: 18),
          Card(
            color: celesteAquadylife.withOpacity(0.13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const ListTile(
              leading: Icon(Icons.lightbulb, color: Color(0xFF43A047)),
              title: Text(
                'Tip de utilidad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF43A047),
                ),
              ),
              subtitle: Text(
                'Puedes usar los sensores para detectar actividad física, orientación o incluso para juegos y seguridad en tu dispositivo.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'AQUADYLIFE',
              style: TextStyle(
                color: verdeAquadylife,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String value;

  const _SensorCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
              radius: 28,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value.isEmpty ? 'Sin datos...' : value,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontFamily: 'monospace',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
