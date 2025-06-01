import 'dart:convert';
import 'package:flutter/material.dart';
// Asegúrate de tener estos paquetes en tu pubspec.yaml:
// google_maps_flutter: ^2.5.0
// geolocator: ^10.0.0
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
            color: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contáctanos")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sobre Nosotros",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Somos AQUADYLIFE, tu tienda de confianza para bebidas saludables y frutos secos. Nos apasiona ofrecer productos de calidad y un excelente servicio.",
                ),
                SizedBox(height: 16),
                Text(
                  "Redes Sociales",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("Facebook: facebook.com/aquadylife"),
                Text("Instagram: @aquadylife"),
                SizedBox(height: 16),
                Text(
                  "Contáctanos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("Teléfono: +51 999 888 777"),
                Text("Correo: contacto@aquadylife.com"),
                SizedBox(height: 16),
                Text(
                  "Ubicación de la tienda",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("Av. Principal 123, Lima, Perú"),
                SizedBox(height: 16),
                Text(
                  "¿Cómo llegar?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "A continuación puedes ver el mapa y la ruta desde tu ubicación actual hasta nuestra tienda.",
                ),
              ],
            ),
          ),
          SizedBox(
            height: 350,
            child:
                (ubicacionUsuario == null || ubicacionTienda == null)
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: ubicacionTienda!,
                        zoom: 14,
                      ),
                      markers: {
                        if (ubicacionUsuario != null)
                          Marker(
                            markerId: const MarkerId('usuario'),
                            position: ubicacionUsuario!,
                            infoWindow: const InfoWindow(title: 'Tu ubicación'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                          ),
                        if (ubicacionTienda != null)
                          Marker(
                            markerId: const MarkerId('tienda'),
                            position: ubicacionTienda!,
                            infoWindow: const InfoWindow(title: 'AQUADYLIFE'),
                          ),
                      },
                      polylines: polylines,
                      onMapCreated: (controller) => mapController = controller,
                    ),
          ),
        ],
      ),
    );
  }
}
