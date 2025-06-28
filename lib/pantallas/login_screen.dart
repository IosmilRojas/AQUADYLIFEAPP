import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function({
    required String nombre,
    required String correo,
    required String celular,
    required String uid,
    required String apellidos,
    required String direccion,
  }) onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final CollectionReference _usuariosRef = FirebaseFirestore.instance
      .collection('USUARIOS');

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    });
  }

  void _showRegisterDialog() {
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _apellidosController = TextEditingController();
    final TextEditingController _correoController = TextEditingController();
    final TextEditingController _celularController = TextEditingController();
    final TextEditingController _dniController = TextEditingController();
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
                  controller: _dniController,
                  decoration: const InputDecoration(labelText: 'DNI'),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
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
                  maxLength: 9,
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
                // Validaciones
                if (_nombreController.text.isEmpty ||
                    _apellidosController.text.isEmpty ||
                    _dniController.text.isEmpty ||
                    _correoController.text.isEmpty ||
                    _celularController.text.isEmpty ||
                    _passRegController.text.isEmpty ||
                    _confirmPassController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                  return;
                }
                if (_dniController.text.length != 8 || int.tryParse(_dniController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('DNI inválido')),
                  );
                  return;
                }
                if (!_correoController.text.contains('@') || !_correoController.text.contains('.')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo inválido')),
                  );
                  return;
                }
                if (_celularController.text.length != 9 || int.tryParse(_celularController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Celular inválido')),
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
                // Verifica si el correo ya existe
                final queryCorreo = await _usuariosRef
                    .where('correoUsuario', isEqualTo: _correoController.text)
                    .get();
                if (queryCorreo.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El correo ya está registrado'),
                    ),
                  );
                  return;
                }
                // Verifica si el DNI ya existe
                final queryDni = await _usuariosRef
                    .where('usuarioId', isEqualTo: _dniController.text)
                    .get();
                if (queryDni.docs.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El DNI ya está registrado'),
                    ),
                  );
                  return;
                }
                // Guarda en Firestore usando el DNI como usuarioId
               await _usuariosRef
                  .doc(_dniController.text)
                  .set({
                    'nombreUsuario': _nombreController.text,
                    'apellidosUsuario': _apellidosController.text,
                    'usuarioId': _dniController.text,
                    'correoUsuario': _correoController.text,
                    'celular': _celularController.text,
                    'password': _passRegController.text,
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
    setState(() => _cargando = true);
    final correo = _userController.text.trim();
    final pass = _passController.text;

    final query = await _usuariosRef
        .where('correoUsuario', isEqualTo: correo)
        .where('password', isEqualTo: pass)
        .get();

    if (query.docs.isNotEmpty) {
      final userData = query.docs.first.data() as Map<String, dynamic>;
      final nombre = userData['nombreUsuario'] ?? '';
      final apellidos = userData['apellidosUsuario'] ?? '';
      final celular = userData['celular'] ?? '';
      final uid = userData['usuarioId'] ?? '';
      final direccion = userData['direccion'] ?? '';
      widget.onLoginSuccess(
        nombre: nombre,
        correo: correo,
        celular: celular,
        uid: uid,
        apellidos: apellidos,
        direccion: direccion,
      );
    } else {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const LoadingScreen(mensaje: "Cargando...");
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
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
