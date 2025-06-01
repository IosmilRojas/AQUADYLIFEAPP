import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantallas/bebidas_page.dart';
import 'pantallas/frutossecos_page.dart';
import 'pantallas/delivery_page.dart';
import 'pantallas/login_screen.dart';

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

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Negocios',
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
              ? Scaffold(
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
                                        () => Navigator.of(context).pop(false),
                                  ),
                                  ElevatedButton(
                                    child: const Text('Salir'),
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          setState(() {
                            _isLoggedIn = false;
                            _currentIndex = 0;
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
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Perfil'),
                        onTap: () {
                          // TODO: Navegar a la pantalla de perfil
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil (en desarrollo)'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Historial de Compras'),
                        onTap: () {
                          // TODO: Navegar a historial de compras
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Historial de Compras (en desarrollo)',
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag),
                        title: const Text('Productos'),
                        onTap: () {
                          // TODO: Navegar a productos
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Productos (en desarrollo)'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_mail),
                        title: const Text('Contáctanos'),
                        onTap: () {
                          // TODO: Navegar a contáctanos
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Contáctanos (en desarrollo)'),
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
                      icon: Icon(Icons.local_drink), // Bebidas
                      label: 'Bebidas',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.spa), // Frutos Secos
                      label: 'Frutos Secos',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.delivery_dining), // Delivery
                      label: 'delivery',
                    ),
                  ],
                ),
              )
              : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return BebidasPage();
      case 1:
        return FrutosSecosPage();
      case 2:
        return DeliveryPage();
      default:
        return BebidasPage();
    }
  }
}
