// lib/pantallas/login_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Definimos un tipo para el callback de éxito de login, que ahora incluye los datos del usuario.
// Usamos un Map para flexibilidad, pero podrías definir una clase de modelo de usuario.
typedef OnLoginSuccessCallback = void Function(Map<String, dynamic> userData);

class LoginScreen extends StatefulWidget {
  final OnLoginSuccessCallback onLoginSuccess; // Cambiamos el tipo del callback

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final CollectionReference _usuariosRef = FirebaseFirestore.instance
      .collection('USUARIOS');

  void _showRegisterDialog() {
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _apellidosController = TextEditingController();
    final TextEditingController _correoController = TextEditingController();
    final TextEditingController _celularController = TextEditingController();
    final TextEditingController _passRegController = TextEditingController();
    final TextEditingController _confirmPassController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ajusta el tamaño del diálogo al contenido
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _apellidosController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                ),
                TextField(
                  controller: _correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _celularController,
                  decoration: const InputDecoration(labelText: 'Celular'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _passRegController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmPassController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                  ),
                  obscureText: true,
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
                    _apellidosController.text.isEmpty ||
                    _correoController.text.isEmpty ||
                    _celularController.text.isEmpty ||
                    _passRegController.text.isEmpty ||
                    _confirmPassController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }
                if (_passRegController.text != _confirmPassController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                    ),
                  );
                  return;
                }
                // Verifica si el correo ya existe en Firestore
                final query =
                    await _usuariosRef
                        .where('correo', isEqualTo: _correoController.text)
                        .get();
                if (query.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El correo ya está registrado'),
                    ),
                  );
                  return;
                }
                // Guarda en Firestore
                await _usuariosRef.add({
                  'nombre': _nombreController.text,
                  'apellidos': _apellidosController.text,
                  'correo': _correoController.text,
                  'celular': _celularController.text,
                  'password':
                      _passRegController
                          .text, // ¡Advertencia: Esto no es seguro!
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usuario registrado correctamente'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    final correo = _userController.text.trim(); // Trim para limpiar espacios
    final pass = _passController.text.trim();

    // Busca el usuario en Firestore
    final querySnapshot =
        await _usuariosRef
            .where('correo', isEqualTo: correo)
            .where(
              'password',
              isEqualTo: pass,
            ) // ¡Advertencia: Esto no es seguro!
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Si se encuentra el usuario, obtenemos sus datos
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final userId = querySnapshot.docs.first.id; // Obtener el ID del documento
      userData['uid'] =
          userId; // Añadir el UID a los datos del usuario para pasarlo

      widget.onLoginSuccess(
        userData,
      ); // Pasamos los datos del usuario al callback
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar en la LoginScreen puede ser opcional o con un estilo diferente
      // appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Center(
        // Centrar todo el contenido
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Cambia la ruta si tu logo está en otro lugar
                height: 120,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenido a AQUADYLIFE',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _userController,
                keyboardType: TextInputType.emailAddress, // Teclado para correo
                decoration: InputDecoration(
                  // Usar InputDecoration del tema
                  labelText: 'Correo',
                  prefixIcon: Icon(
                    Icons.email_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: InputDecoration(
                  // Usar InputDecoration del tema
                  labelText: 'Contraseña',
                  prefixIcon: Icon(
                    Icons.lock_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    // Para que los botones ocupen el espacio disponible
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('Ingresar'),
                    ),
                  ),
                  const SizedBox(width: 16), // Espacio entre botones
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showRegisterDialog,
                      child: const Text('Registrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context)
                                .colorScheme
                                .secondary, // Usar color de acento del tema
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
