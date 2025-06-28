import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantallas/bebidas_page.dart';
import 'pantallas/menu_principal.dart';
import 'pantallas/delivery_page.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/contactanos.dart';
import 'pantallas/perfil_page.dart';
import 'pantallas/Historial_compras.dart';
import 'pantallas/TodosLosSensoresScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'admin_dashboard.dart';

const verdeAquadylife = Color(0xFF43A047);
const celesteAquadylife = Color(0xFF4FC3F7);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AppWrapper());
}

/// MaterialApp separado para evitar problemas de contexto
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Si es web, muestra el dashboard de admin
    if (kIsWeb) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Administrador Flutter',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const AdminDashboard(),
      );
    }
    // Si es móvil, muestra la app normal
    return MaterialApp(
      title: 'AQUADYLIFE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  Future<void> _onLoginSuccess({
    required String correo,
    required String nombre,
    String? celular,
    String? uid,
    String? apellidos,
    String? direccion,
  }) async {
    final doc =
        await FirebaseFirestore.instance.collection('USUARIOS').doc(uid).get();
    setState(() {
      _isLoggedIn = true;
      _userData = {
        'correo': correo,
        'nombre': nombre,
        'celular': celular ?? '',
        'uid': uid ?? '',
        'apellidos': apellidos ?? '',
        'direccion': direccion ?? '',
        'fotoPerfilBase64': doc.data()?['fotoPerfilBase64'] ?? '',
      };
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _currentIndex = 0;
      _userData = null;
    });
  }

  Widget _buildDrawer() {
    return Builder(
      builder: (drawerContext) => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [verdeAquadylife, celesteAquadylife],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: celesteAquadylife.withOpacity(0.15),
                    backgroundImage:
                        (_userData?['fotoPerfilBase64'] ?? '').isNotEmpty
                            ? MemoryImage(
                                base64Decode(_userData!['fotoPerfilBase64']),
                              )
                            : null,
                    child: (_userData?['fotoPerfilBase64'] ?? '').isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userData?['nombre'] ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: verdeAquadylife),
              title: const Text('Perfil'),
              onTap: () async {
                Navigator.of(drawerContext).pop();
                if (_userData != null) {
                  await Navigator.push(
                    drawerContext,
                    MaterialPageRoute(
                      builder: (context) => PerfilPage(
                        userId: _userData!['uid'],
                        correoUsuario: _userData!['correo'],
                        nombreUsuario: _userData!['nombre'],
                        apellidosUsuario: _userData!['apellidos'],
                        celular: _userData!['celular'],
                        direccion: _userData!['direccion'],
                      ),
                    ),
                  );
                  final doc = await FirebaseFirestore.instance
                      .collection('USUARIOS')
                      .doc(_userData!['uid'])
                      .get();
                  setState(() {
                    _userData!['fotoPerfilBase64'] =
                        doc.data()?['fotoPerfilBase64'] ?? '';
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: verdeAquadylife),
              title: const Text('Historial de Compras'),
              onTap: () {
                Navigator.of(drawerContext).pop();
                Navigator.push(
                  drawerContext,
                  MaterialPageRoute(
                    builder: (_) => HistorialPedidosScreen(
                      userEmail: _userData?['correo'] ?? '',
                      userName: _userData?['nombre'] ?? '',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: verdeAquadylife),
              title: const Text('Productos'),
              onTap: () {
                Navigator.of(drawerContext).pop();
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail, color: verdeAquadylife),
              title: const Text('Contáctanos'),
              onTap: () {
                Navigator.of(drawerContext).pop();
                Navigator.push(
                  drawerContext,
                  MaterialPageRoute(
                    builder: (_) => const ContactanosPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sensors, color: verdeAquadylife),
              title: const Text('Sensores del Móvil'),
              onTap: () {
                Navigator.of(drawerContext).pop();
                Navigator.push(
                  drawerContext,
                  MaterialPageRoute(
                    builder: (context) => const TodosLosSensoresScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return MenuPrincipal();
      case 1:
        return BebidasPage(
          userId: _userData!['uid'],
          nombreUsuario: _userData!['nombre'],
          apellidosUsuario: _userData!['apellidos'],
          correoUsuario: _userData!['correo'],
        );
      case 2:
        return DeliveryPage();
      default:
        return MenuPrincipal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? Scaffold(
            appBar: AppBar(
              title: const Text('AQUADYLIFE'),
              backgroundColor: verdeAquadylife,
              foregroundColor: Colors.white,
              actions: [
                Builder(
                  builder: (scaffoldContext) => IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Salir',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: scaffoldContext,
                        builder: (context) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text(
                            '¿Estás seguro que deseas salir de la sesión?',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: celesteAquadylife,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Salir'),
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        if (Scaffold.of(scaffoldContext).isDrawerOpen) {
                          Navigator.of(scaffoldContext).pop();
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                        }
                        if (mounted) {
                          setState(() {
                            _logout();
                          });
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            drawer: _buildDrawer(),
            body: _getBody(),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              selectedItemColor: verdeAquadylife,
              unselectedItemColor: celesteAquadylife,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_drink),
                  label: 'Bebidas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delivery_dining),
                  label: 'Delivery',
                ),
              ],
            ),
          )
        : LoginScreen(onLoginSuccess: _onLoginSuccess);
  }
}
