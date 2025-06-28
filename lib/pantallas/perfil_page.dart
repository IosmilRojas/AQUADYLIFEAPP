import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilPage extends StatefulWidget {
  final String userId,
      correoUsuario,
      nombreUsuario,
      apellidosUsuario,
      celular,
      direccion;

  const PerfilPage({
    Key? key,
    required this.userId,
    required this.correoUsuario,
    required this.nombreUsuario,
    this.apellidosUsuario = '',
    this.celular = '',
    this.direccion = 'Dirección no especificada',
  }) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late TextEditingController _nameController,
      _lastNameController,
      _phoneController,
      _addressController,
      _dniController;
  bool _isEditing = false, _subiendoImagen = false;
  File? _imagenTemporal;
  String? _imagenGuardada, _dni = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _dniController = TextEditingController();
    _cargarDatosUsuario();
    _cargarImagenPerfil();
  }

  Future<void> _cargarDatosUsuario() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('USUARIOS')
            .doc(widget.userId)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['nombreUsuario'] ?? '';
        _lastNameController.text = data['apellidosUsuario'] ?? '';
        _phoneController.text = data['celular'] ?? '';
        _addressController.text =
            data['direccion'] ?? 'Dirección no especificada';
        _dni = data['usuarioId'] ?? '';
        _dniController.text = _dni ?? '';
      });
    }
  }

  Future<void> _cargarImagenPerfil() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('USUARIOS')
            .doc(widget.userId)
            .get();
    final foto = doc.data()?['fotoPerfilBase64'] as String?;
    if (foto != null && foto.isNotEmpty) setState(() => _imagenGuardada = foto);
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.length() > 2 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen no debe exceder 2MB')),
        );
        return;
      }
      setState(() => _imagenTemporal = file);
    }
  }

  Future<void> _subirImagen() async {
    if (_imagenTemporal == null || widget.userId.isEmpty) return;
    setState(() => _subiendoImagen = true);
    final bytes = await _imagenTemporal!.readAsBytes();
    if (bytes.length > 900 * 1024) {
      setState(() => _subiendoImagen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La imagen es demasiado grande para subir a Firestore.',
          ),
        ),
      );
      return;
    }
    final base64Image = base64Encode(bytes);
    await FirebaseFirestore.instance
        .collection('USUARIOS')
        .doc(widget.userId)
        .update({'fotoPerfilBase64': base64Image});
    setState(() {
      _imagenGuardada = base64Image;
      _imagenTemporal = null;
      _subiendoImagen = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto actualizada correctamente')),
    );
  }

  ImageProvider? _obtenerImagenPerfil() {
    if (_imagenTemporal != null) return FileImage(_imagenTemporal!);
    if (_imagenGuardada != null && _imagenGuardada!.isNotEmpty)
      return MemoryImage(base64Decode(_imagenGuardada!));
    return null;
  }

  void _saveProfile() async {
    await FirebaseFirestore.instance
        .collection('USUARIOS')
        .doc(widget.userId)
        .update({
          'nombreUsuario': _nameController.text,
          'apellidosUsuario': _lastNameController.text,
          'celular': _phoneController.text,
          'direccion': _addressController.text.trim(),
          'usuarioId': _dniController.text.trim(),
        });
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1976D2);
    const Color accentColor = Color(0xFF43A047);
    const Color cardBg = Color(0xFFE3F2FD);
    const Color bgColor = Color(0xFFE8F5E9);
    const Color logoutColor = Color(0xFF424242);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded),
            tooltip: _isEditing ? 'Guardar cambios' : 'Editar perfil',
            onPressed: () {
              if (_isEditing) {
                _saveProfile(); // Llama la función async fuera de setState
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: accentColor.withOpacity(0.15),
                  backgroundImage: _obtenerImagenPerfil(),
                  child:
                      _subiendoImagen
                          ? const CircularProgressIndicator()
                          : (_imagenTemporal == null && _imagenGuardada == null)
                          ? Icon(
                            Icons.person_rounded,
                            size: 70,
                            color: primaryColor,
                          )
                          : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(
                          Icons.image,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: _mostrarDialogoSeleccionImagen,
                        tooltip: 'Actualizar foto de perfil',
                      ),
                    ),
                  ),
              ],
            ),
            if (_imagenTemporal != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _subiendoImagen ? null : _subirImagen,
                  child:
                      _subiendoImagen
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text('Guardar Foto'),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _nameController.text,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.correoUsuario,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(
              title: 'Información Personal',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildInfoRow(
                  icon: Icons.credit_card,
                  label: 'DNI',
                  controller: _dniController,
                  isEditable: _isEditing,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  label: 'Nombre',
                  controller: _nameController,
                  isEditable: _isEditing,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Apellidos',
                  controller: _lastNameController,
                  isEditable: _isEditing,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Teléfono',
                  controller: _phoneController,
                  isEditable: _isEditing,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Dirección',
                  controller: _addressController,
                  isEditable: _isEditing,
                  iconColor: accentColor,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Configuración de Cuenta',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildSettingItem(
                  icon: Icons.lock_rounded,
                  title: 'Cambiar Contraseña',
                  onTap: () => _showDevMsg('Cambiar Contraseña'),
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  icon: Icons.credit_card_rounded,
                  title: 'Métodos de Pago',
                  onTap: () => _showDevMsg('Métodos de Pago'),
                  iconColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Soporte y Legal',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildSettingItem(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Política de Privacidad',
                  onTap: () => _showDevMsg('Política de Privacidad'),
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  icon: Icons.description_rounded,
                  title: 'Términos y Condiciones',
                  onTap: () => _showDevMsg('Términos y Condiciones'),
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda y Preguntas Frecuentes',
                  onTap: () => _showDevMsg('Ayuda'),
                  iconColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro de que quieres cerrar tu sesión?',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Sí, Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: logoutColor,
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: logoutColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    Color cardColor = Colors.white,
    Color titleColor = Colors.black,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isEditable = false,
    int? maxLines = 1,
    Color iconColor = Colors.blue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                isEditable
                    ? TextField(
                      controller: controller,
                      maxLines: maxLines,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 0,
                        ),
                        border: const UnderlineInputBorder(),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: iconColor, width: 2.0),
                        ),
                      ),
                    )
                    : Text(
                      controller.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      tileColor: Colors.transparent,
      hoverColor: iconColor.withOpacity(0.05),
      selectedTileColor: iconColor.withOpacity(0.03),
    );
  }

  void _mostrarDialogoSeleccionImagen() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Actualizar foto de perfil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Elegir de galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDevMsg(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$msg (en desarrollo)')));
  }
}
