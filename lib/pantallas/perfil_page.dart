import 'dart:io';
import 'dart:convert'; // <-- Agrega esto
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilPage extends StatefulWidget {
  final String userId; // ¡Importante! El ID del documento en Firestore
  final String userEmail;
  final String userName;
  final String userLastName; // Asumiendo que también pasas el apellido
  final String userPhone;
  final String userAddress; // Asumiendo que también pasas la dirección

  const PerfilPage({
    Key? key,
    required this.userId, // Hacer que userId sea requerido
    required this.userEmail,
    required this.userName,
    this.userLastName = '', // Valor por defecto si no se pasa
    this.userPhone = '',
    this.userAddress = 'Dirección no especificada',
  }) : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Variables para la información del usuario
  late String _userName;
  late String _userEmail;
  late String _userLastName;
  late String _userPhone;
  late String _userAddress;

  // Controladores para los campos de texto editables
  late TextEditingController _nameController;
  late TextEditingController
  _lastNameController; // Controlador para el apellido
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isEditing =
      false; // Estado para controlar si se está editando el perfil
  String? _imagenBase64;
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inicializa las variables de estado con los datos pasados por el constructor
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _userLastName = widget.userLastName;
    _userPhone =
        widget.userPhone.isEmpty ? '+51 987 654 321' : widget.userPhone;
    _userAddress =
        widget.userAddress.isEmpty
            ? 'Dirección no especificada'
            : widget.userAddress;

    _nameController = TextEditingController(text: _userName);
    _lastNameController = TextEditingController(text: _userLastName);
    _phoneController = TextEditingController(text: _userPhone);
    _addressController = TextEditingController(text: _userAddress);

    _obtenerFotoPerfil();
  }

  @override
  void didUpdateWidget(covariant PerfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualiza los controladores si los datos del widget cambian
    if (widget.userEmail != oldWidget.userEmail ||
        widget.userName != oldWidget.userName ||
        widget.userLastName != oldWidget.userLastName ||
        widget.userPhone != oldWidget.userPhone ||
        widget.userAddress != oldWidget.userAddress) {
      setState(() {
        _userName = widget.userName;
        _userEmail = widget.userEmail;
        _userLastName = widget.userLastName;
        _userPhone =
            widget.userPhone.isEmpty ? '+51 987 654 321' : widget.userPhone;
        _userAddress =
            widget.userAddress.isEmpty
                ? 'Dirección no especificada'
                : widget.userAddress;

        _nameController.text = _userName;
        _lastNameController.text = _userLastName;
        _phoneController.text = _userPhone;
        _addressController.text = _userAddress;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Función para guardar los cambios en Firestore
  void _saveProfile() async {
    setState(() {
      _userName = _nameController.text;
      _userLastName = _lastNameController.text;
      _userPhone = _phoneController.text;
      _userAddress = _addressController.text;
      _isEditing = false; // Desactivar modo edición
    });

    try {
      await FirebaseFirestore.instance
          .collection('USUARIOS')
          .doc(widget.userId)
          .update({
            'nombre': _userName,
            'apellidos': _userLastName,
            'celular': _userPhone,
            'direccion':
                _userAddress, // Asegúrate de que este campo exista en Firestore
            // No actualizamos el correo ni la contraseña desde aquí por simplicidad,
            // pero la lógica sería similar si lo permitieras.
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _obtenerFotoPerfil() async {
    if (widget.userId.isEmpty) return; // <-- Validación agregada
    final doc =
        await FirebaseFirestore.instance
            .collection('USUARIOS')
            .doc(widget.userId)
            .get();

    final data = doc.data();
    if (data != null && data['fotoPerfilBase64'] != null) {
      setState(() {
        _imagenBase64 = data['fotoPerfilBase64'];
      });
    }
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 50);
    if (picked == null) return;

    setState(() {
      _imagenSeleccionada = File(picked.path);
    });
  }

  Future<void> _subirImagen() async {
    if (_imagenSeleccionada == null || widget.userId.isEmpty)
      return; // <-- Validación agregada

    final bytes = await _imagenSeleccionada!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final docRef = FirebaseFirestore.instance
        .collection('USUARIOS')
        .doc(widget.userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.update({'fotoPerfilBase64': base64Image});
    } else {
      await docRef.set({'fotoPerfilBase64': base64Image});
    }

    if (!mounted) return;
    setState(() {
      _imagenBase64 = base64Image;
      _imagenSeleccionada = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen de perfil actualizada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paleta corporativa ajustada
    const Color primaryColor = Color(0xFF1976D2); // Azul corporativo
    const Color accentColor = Color(0xFF43A047); // Verde corporativo
    const Color cardBg = Color(0xFFE3F2FD); // Celeste claro
    const Color bgColor = Color(0xFFE8F5E9); // Verde muy claro, saludable
    const Color logoutColor = Color(
      0xFF424242,
    ); // Gris oscuro para cerrar sesión

    ImageProvider<Object>? imageWidget;
    if (_imagenSeleccionada != null) {
      imageWidget = FileImage(_imagenSeleccionada!);
    } else if (_imagenBase64 != null) {
      try {
        final bytes = base64Decode(_imagenBase64!);
        imageWidget = MemoryImage(bytes);
      } catch (e) {
        imageWidget = null;
      }
    }

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
              setState(() {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  _isEditing = true;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: accentColor.withOpacity(0.15),
                  backgroundImage: imageWidget,
                  child:
                      imageWidget == null
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
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => _seleccionarImagen(ImageSource.gallery),
                            tooltip: 'Seleccionar de galería',
                          ),
                        ),
                        const SizedBox(height: 4),
                        CircleAvatar(
                          backgroundColor: accentColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => _seleccionarImagen(ImageSource.camera),
                            tooltip: 'Tomar foto',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_imagenSeleccionada != null && _isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                  onPressed: _subirImagen,
                  icon: const Icon(Icons.check),
                  label: const Text("Guardar imagen"),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),

            _buildInfoCard(
              context,
              title: 'Información Personal',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Nombre',
                  value: _userName,
                  isEditable: _isEditing,
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: 'Apellidos',
                  value: _userLastName,
                  isEditable: _isEditing,
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.phone_rounded,
                  label: 'Teléfono',
                  value: _userPhone,
                  isEditable: _isEditing,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  iconColor: accentColor,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_rounded,
                  label: 'Dirección',
                  value: _userAddress,
                  isEditable: _isEditing,
                  controller: _addressController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  iconColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              context,
              title: 'Configuración de Cuenta',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildSettingItem(
                  context,
                  icon: Icons.lock_rounded,
                  title: 'Cambiar Contraseña',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cambiar Contraseña (en desarrollo)'),
                      ),
                    );
                  },
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.credit_card_rounded,
                  title: 'Métodos de Pago',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Métodos de Pago (en desarrollo)'),
                      ),
                    );
                  },
                  iconColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              context,
              title: 'Soporte y Legal',
              cardColor: cardBg,
              titleColor: primaryColor,
              children: [
                _buildSettingItem(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: 'Política de Privacidad',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Política de Privacidad (en desarrollo)'),
                      ),
                    );
                  },
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.description_rounded,
                  title: 'Términos y Condiciones',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Términos y Condiciones (en desarrollo)'),
                      ),
                    );
                  },
                  iconColor: accentColor,
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda y Preguntas Frecuentes',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ayuda (en desarrollo)')),
                    );
                  },
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
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                            child: const Text('Sí, Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: logoutColor, // Gris oscuro
                            ),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: logoutColor, // Gris oscuro
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

  // Cambia los widgets auxiliares para aceptar color de tarjeta, título e íconos:
  Widget _buildInfoCard(
    BuildContext context, {
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

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
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
                      keyboardType: keyboardType,
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
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: iconColor, width: 2.0),
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
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
}
