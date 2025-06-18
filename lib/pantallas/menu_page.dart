import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  // Añadimos un callback para notificar al padre sobre la navegación.
  final ValueChanged<int> onNavigateToTab;

  const MenuPage({
    Key? key,
    required this.onNavigateToTab, // Hacemos el callback requerido
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección de Anuncios/Banners (Puedes usar un CarouselSlider aquí para múltiples imágenes)
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.only(bottom: 20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Imagen de fondo del anuncio
                  Image.asset(
                    'assets/drawer_background.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.blueGrey[100],
                      child: const Center(
                        child: Text(
                          'Fondo de anuncio',
                          style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  // Texto superpuesto en el anuncio
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.4),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¡Grandes Ofertas Semanales!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Descuentos exclusivos en tus bebidas y frutos secos favoritos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
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

          
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget auxiliar para construir filas de información
  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para botones de acción rápida
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: IconButton(
            icon: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            onPressed: onTap,
            tooltip: label,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
