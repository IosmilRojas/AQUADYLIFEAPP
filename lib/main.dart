import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantallas/bebidas_page.dart';
import 'pantallas/menu_principal.dart';
import 'pantallas/delivery_page.dart';
import 'pantallas/login_screen.dart';
import 'pantallas/contactanos.dart';
import 'pantallas/perfil_page.dart';
import 'pantallas/ventas_page.dart'; // <--- CORREGIDO EL NOMBRE DEL ARCHIVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  String? _nombreUsuario;
  String? _correoUsuario;

  Map<String, dynamic>? _loggedInUserData;

  void _onLoginSuccess({
    required String correo,
    required String nombre,
    String? celular,
    String? uid,
    String? apellidos,
    String? direccion,
  }) {
    setState(() {
      _isLoggedIn = true;
      _nombreUsuario = nombre;
      _correoUsuario = correo;
      _loggedInUserData = {
        'correo': correo,
        'nombre': nombre,
        'celular': celular ?? '',
        'uid': uid ?? '',
        'apellidos': apellidos ?? '',
        'direccion': direccion ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home:
          _isLoggedIn
              ? Builder(
                builder:
                    (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('AQUADYLIFE'),
                        backgroundColor: Colors.indigo,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            tooltip: 'Salir',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Cerrar sesión'),
                                      content: const Text(
                                        '¿Estás seguro que deseas salir de la sesión?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancelar'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                        ),
                                        ElevatedButton(
                                          child: const Text('Salir'),
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                setState(() {
                                  _isLoggedIn = false;
                                  _currentIndex = 0;
                                  _nombreUsuario = null;
                                  _correoUsuario = null;
                                  _loggedInUserData = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      drawer: Drawer(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            const DrawerHeader(
                              decoration: BoxDecoration(color: Colors.indigo),
                              child: Text(
                                'Menú',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Perfil'),
                              onTap: () {
                                Navigator.pop(context);
                                if (_loggedInUserData != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PerfilPage(
                                            userEmail:
                                                _loggedInUserData!['correo'],
                                            userName:
                                                _loggedInUserData!['nombre'],
                                            userPhone:
                                                _loggedInUserData!['celular'],
                                            userId: _loggedInUserData!['uid'],
                                            userLastName:
                                                _loggedInUserData!['apellidos'],
                                            userAddress:
                                                _loggedInUserData!['direccion'] ??
                                                'Dirección no especificada',
                                          ),
                                    ),
                                  );
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.history),
                              title: const Text('Historial de Compras'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistorialPedidosScreen(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.shopping_bag),
                              title: const Text('Productos'),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentIndex = 0;
                                });
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.contact_mail),
                              title: const Text('Contáctanos'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ContactanosPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      body: _getBody(),
                      bottomNavigationBar: BottomNavigationBar(
                        backgroundColor: Colors.white,
                        currentIndex: _currentIndex,
                        selectedItemColor: Colors.indigo,
                        unselectedItemColor: Colors.grey,
                        onTap: (index) => setState(() => _currentIndex = index),
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Menu Principal',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.local_drink),
                            label: 'Bebidas',
                          ),

                          BottomNavigationBarItem(
                            icon: Icon(Icons.delivery_dining),
                            label: 'delivery',
                          ),
                        ],
                      ),
                    ),
              )
              : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return MenuPrincipal();
      case 1:
        return BebidasPage();
      case 2:
        return DeliveryPage();
      default:
        return MenuPrincipal();
    }
  }
}
