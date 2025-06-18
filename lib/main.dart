import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Asegúrate de que estas rutas sean correctas para tus archivos de pantalla.
import 'pantallas/bebidas_page.dart';
import 'pantallas/menu_page.dart';
import 'pantallas/delivery_page.dart';
import 'pantallas/login_screen.dart'; // Importa la pantalla de login
import 'pantallas/perfil_page.dart'; // Importa la pantalla de perfil
// ELIMINAR: import 'package:aquadylife/frutos_secos_page.dart';
// AGREGADO: Importa tu nueva pantalla de contacto
import 'pantallas/contactanos_page.dart';

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
  Map<String, dynamic>?
      _loggedInUserData; // Almacenará los datos del usuario logueado

  // Este callback se llama desde LoginScreen cuando el login es exitoso
  void _onLoginSuccess(Map<String, dynamic> userData) {
    setState(() {
      _loggedInUserData = userData; // Guarda los datos del usuario
    });
  }

  // Método para cerrar sesión y limpiar los datos del usuario
  void _logout() async {
    setState(() {
      _loggedInUserData = null; // Limpia los datos del usuario
      _currentIndex = 0; // Reinicia a la primera pestaña
    });
    // Si tuvieras persistencia de login (ej. SharedPreferences), la borrarías aquí.
  }

  // Método _changeTab para cambiar el índice del BottomNavigationBar
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = _loggedInUserData != null;

    return MaterialApp(
      title: 'Gestión de Negocios AQUADYLIFE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.light().copyWith(
          primary: const Color.fromARGB(255, 53, 207, 227),
          onPrimary: Colors.white,
          secondary: const Color.fromARGB(255, 53, 207, 227),
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.grey[50],
          onBackground: Colors.black87,
          error: Colors.red[700],
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 53, 207, 227),
          foregroundColor: Colors.white,
          elevation: 4.0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIconColor: const Color.fromARGB(255, 53, 207, 227),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 53, 207, 227),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 5,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 53, 207, 227),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
      ),
      home: isLoggedIn
          ? Scaffold(
              appBar: AppBar(
                title: const Text('AQUADYLIFE'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'Cerrar sesión',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Cerrar sesión?'),
                          content: const Text(
                            'Estás a punto de salir de tu cuenta. ¿Estás seguro?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            ElevatedButton(
                              child: const Text('Sí, salir'),
                              onPressed: () {
                                _logout(); // Llama a tu función de cerrar sesión
                                Navigator.of(context).pop(true); // Cierra el diálogo
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              drawer: Drawer(
                child: Builder(
                  builder: (BuildContext drawerContext) {
                    String userName = _loggedInUserData?['nombre'] ?? 'Invitado';
                    String userEmail = _loggedInUserData?['correo'] ?? 'No logueado';

                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        DrawerHeader(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            16.0,
                            16.0,
                            8.0,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 53, 207, 227),
                                Color.fromARGB(255, 80, 220, 240),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 45,
                                  color: Color.fromARGB(255, 53, 207, 227),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildDrawerItem(
                          icon: Icons.account_circle,
                          title: 'Mi Perfil',
                          onTap: () {
                            Navigator.pop(drawerContext);
                            if (_loggedInUserData != null) {
                              Navigator.push(
                                drawerContext,
                                MaterialPageRoute(
                                  builder: (context) => PerfilPage(
                                    userEmail: _loggedInUserData!['correo'],
                                    userName: _loggedInUserData!['nombre'],
                                    userPhone: _loggedInUserData!['celular'],
                                    userId: _loggedInUserData!['uid'],
                                    userLastName: _loggedInUserData!['apellidos'],
                                    userAddress: _loggedInUserData!['direccion'] ??
                                        'Dirección no especificada',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(drawerContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No hay datos de usuario para mostrar.',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.history_rounded,
                          title: 'Historial de Pedidos',
                          onTap: () {
                            Navigator.pop(drawerContext);
                            ScaffoldMessenger.of(drawerContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Historial de Pedidos (en desarrollo)',
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  53,
                                  207,
                                  227,
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        
                        _buildDrawerItem(
                          icon: Icons.contact_support_rounded,
                          title: 'Contactanos',
                          onTap: () {
                            Navigator.pop(drawerContext); // Cierra el Drawer
                            // Navega a la pantalla de ContactanosPage
                            Navigator.push(
                              drawerContext,
                              MaterialPageRoute(
                                builder: (context) => const ContactanosPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          height: 30,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Versión 1.0.0',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              body: _getBody(),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  currentIndex: _currentIndex,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.grey[600],
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Menú Principal',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.local_drink_outlined),
                      activeIcon: Icon(Icons.local_drink_rounded),
                      label: 'Bebidas',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.delivery_dining_outlined),
                      activeIcon: Icon(Icons.delivery_dining_rounded),
                      label: 'Delivery',
                    ),
                  ],
                ),
              ),
            )
          : LoginScreen(
              onLoginSuccess: _onLoginSuccess,
            ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 53, 207, 227)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hoverColor: const Color.fromARGB(255, 53, 207, 227).withOpacity(0.1),
        selectedTileColor: const Color.fromARGB(
          255,
          53,
          207,
          227,
        ).withOpacity(0.05),
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return MenuPage(onNavigateToTab: _changeTab);
      case 1:
        return BebidasPage();
      case 2: // Antes era Frutos Secos, ahora será Delivery
        return DeliveryPage();
      default:
        return MenuPage(onNavigateToTab: _changeTab);
    }
  }
}
