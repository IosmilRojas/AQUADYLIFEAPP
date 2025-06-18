import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ContactanosPage extends StatefulWidget {
  const ContactanosPage({Key? key}) : super(key: key);

  @override
  State<ContactanosPage> createState() => _ContactanosPageState();
}

class _ContactanosPageState extends State<ContactanosPage> {
  LatLng? ubicacionUsuario;
  LatLng? ubicacionTienda;
  GoogleMapController? mapController;
  Set<Polyline> polylines = {};
  final String apiKey = "AIzaSyBIZrptkE0IGakPhzMzMpq4PaW_gw_D1vk";

  @override
  void initState() {
    super.initState();
    obtenerUbicacionUsuario();
    obtenerUbicacionTienda();
  }

  Future<void> obtenerUbicacionUsuario() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) return;
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) return;
    }
    if (permiso == LocationPermission.deniedForever) return;
    Position posicion = await Geolocator.getCurrentPosition();
    setState(() {
      ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);
    });
    if (ubicacionTienda != null) obtenerRuta();
  }

  Future<void> obtenerUbicacionTienda() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('tienda')
            .doc('principal')
            .get();
    final data = snapshot.data();
    if (data != null && data['tienda'] != null) {
      final geo = data['tienda'] as GeoPoint;
      setState(() {
        ubicacionTienda = LatLng(geo.latitude, geo.longitude);
      });
      if (ubicacionUsuario != null) obtenerRuta();
    }
  }

  Future<void> obtenerRuta() async {
    if (ubicacionUsuario == null || ubicacionTienda == null) return;
    final origen =
        "${ubicacionUsuario!.latitude},${ubicacionUsuario!.longitude}";
    final destino =
        "${ubicacionTienda!.latitude},${ubicacionTienda!.longitude}";
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?origin=$origen&destination=$destino&key=$apiKey&mode=driving",
    );
    final respuesta = await http.get(url);
    if (respuesta.statusCode == 200) {
      final data = json.decode(respuesta.body);
      final puntos = data["routes"][0]["overview_polyline"]["points"];
      final ruta = decodePolyline(puntos);
      setState(() {
        polylines = {
          Polyline(
            polylineId: const PolylineId("ruta"),
            color: Colors.green.shade700,
            width: 5,
            points: ruta,
          ),
        };
      });
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return polyline;
  }

  void _abrirEnlace(String url) async {
    // Usa url_launcher para abrir enlaces externos
    // Asegúrate de agregar url_launcher a pubspec.yaml
    // url_launcher: ^6.2.6
    // import 'package:url_launcher/url_launcher.dart';
    // Si no tienes url_launcher, solo muestra un SnackBar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Abrir: $url')));
  }

  @override
  Widget build(BuildContext context) {
    // Colores ecoamigables
    const Color celeste = Color(0xFF4FC3F7);
    const Color verde = Color(0xFF43A047);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contáctanos"),
        backgroundColor: celeste,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: celeste.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 80),
                    const SizedBox(height: 8),
                    const Text(
                      "AQUADYLIFE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color(0xFF43A047),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sobre Nosotros",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: verde,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Somos AQUADYLIFE, tu tienda de confianza para bebidas saludables y frutos secos. Nos apasiona ofrecer productos de calidad y un excelente servicio.",
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Redes Sociales",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: celeste,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap:
                            () =>
                                _abrirEnlace('https://facebook.com/aquadylife'),
                        child: Row(
                          children: [
                            Icon(Icons.facebook, color: celeste, size: 20),
                            const SizedBox(width: 6),
                            const Text("facebook.com/aquadylife"),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => _abrirEnlace(
                              'https://instagram.com/aquadylife',
                            ),
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, color: verde, size: 20),
                            const SizedBox(width: 6),
                            const Text("Instagram: @aquadylife"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Contáctanos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: verde,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _abrirEnlace('tel:+51999888777'),
                        child: Row(
                          children: [
                            Icon(Icons.phone, color: celeste, size: 20),
                            const SizedBox(width: 6),
                            const Text("Teléfono: +51 999 888 777"),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap:
                            () =>
                                _abrirEnlace('mailto:contacto@aquadylife.com'),
                        child: Row(
                          children: [
                            Icon(Icons.email, color: verde, size: 20),
                            const SizedBox(width: 6),
                            const Text("contacto@aquadylife.com"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Ubicación de la tienda",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: celeste,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap:
                            () => _abrirEnlace(
                              'https://www.google.com/maps/search/?api=1&query=-12.0464,-77.0428',
                            ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: verde, size: 20),
                            const SizedBox(width: 6),
                            const Text("Av. Principal 123, Lima, Perú"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "¿Cómo llegar?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: verde,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "A continuación puedes ver el mapa y la ruta desde tu ubicación actual hasta nuestra tienda.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SizedBox(
                  height: 350,
                  child:
                      (ubicacionUsuario == null || ubicacionTienda == null)
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: ubicacionTienda!,
                                zoom: 14,
                              ),
                              markers: {
                                if (ubicacionUsuario != null)
                                  Marker(
                                    markerId: const MarkerId('usuario'),
                                    position: ubicacionUsuario!,
                                    infoWindow: const InfoWindow(
                                      title: 'Tu ubicación',
                                    ),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueAzure,
                                    ),
                                  ),
                                if (ubicacionTienda != null)
                                  Marker(
                                    markerId: const MarkerId('tienda'),
                                    position: ubicacionTienda!,
                                    infoWindow: const InfoWindow(
                                      title: 'AQUADYLIFE',
                                    ),
                                  ),
                              },
                              polylines: polylines,
                              onMapCreated:
                                  (controller) => mapController = controller,
                            ),
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}