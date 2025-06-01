import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final CollectionReference _usuariosRef =
      FirebaseFirestore.instance.collection('USUARIOS');

  void _showRegisterDialog() {
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _apellidosController = TextEditingController();
    final TextEditingController _correoController = TextEditingController();
    final TextEditingController _celularController = TextEditingController();
    final TextEditingController _passRegController = TextEditingController();
    final TextEditingController _confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Usuario'),
          content: SingleChildScrollView(
            child: Column(
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
                  decoration: const InputDecoration(labelText: 'Confirmar Contraseña'),
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
                    const SnackBar(content: Text('Las contraseñas no coinciden')),
                  );
                  return;
                }
                // Verifica si el correo ya existe en Firestore
                final query = await _usuariosRef
                    .where('correo', isEqualTo: _correoController.text)
                    .get();
                if (query.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El correo ya está registrado')),
                  );
                  return;
                }
                // Guarda en Firestore
                await _usuariosRef.add({
                  'nombre': _nombreController.text,
                  'apellidos': _apellidosController.text,
                  'correo': _correoController.text,
                  'celular': _celularController.text,
                  'password': _passRegController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario registrado correctamente')),
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
    final correo = _userController.text;
    final pass = _passController.text;

    // Busca el usuario en Firestore
    final query = await _usuariosRef
        .where('correo', isEqualTo: correo)
        .where('password', isEqualTo: pass)
        .get();

    if (query.docs.isNotEmpty) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGO AQUÍ
            Image.asset(
              'assets/logo.png', // Cambia la ruta si tu logo está en otro lugar
              height: 120,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Ingresar'),
                ),
                ElevatedButton(
                  onPressed: _showRegisterDialog,
                  child: const Text('Registrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}