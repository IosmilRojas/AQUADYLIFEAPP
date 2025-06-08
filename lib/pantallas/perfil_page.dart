// lib/pantallas/perfil_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importar Firestore

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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: 70,
                    color: primaryColor,
                  ),
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
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cambiar foto (en desarrollo)'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userEmail,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            _buildInfoCard(
              context,
              title: 'Información Personal',
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Nombre',
                  value: _userName,
                  isEditable: _isEditing,
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                ),
                _buildInfoRow(
                  // Nuevo campo para Apellidos
                  context,
                  icon:
                      Icons.person_outline_rounded, // Otro icono para apellidos
                  label: 'Apellidos',
                  value: _userLastName,
                  isEditable: _isEditing,
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.phone_rounded,
                  label: 'Teléfono',
                  value: _userPhone,
                  isEditable: _isEditing,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
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
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              context,
              title: 'Configuración de Cuenta',
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
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInfoCard(
              context,
              title: 'Soporte y Legal',
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
                              // Simplemente cierra el diálogo, MyApp manejará el logout
                              Navigator.of(ctx).pop(true);
                              // En la vida real, aquí le dirías a MyApp que haga logout.
                              // Por ejemplo, con Provider o otro State Management.
                              // O podrías hacer Navigator.pop() para regresar a MyApp,
                              // y MyApp se encargará de mostrar LoginScreen.
                            },
                            child: const Text('Sí, Cerrar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  // Necesitamos un mecanismo para notificar a MyApp que cierre sesión.
                  // La forma más sencilla es que MyApp reciba el resultado y actúe.
                  // Para este ejemplo, simplemente regresaremos a la pantalla anterior,
                  // que será el scaffold principal gestionado por MyApp, y allí se activa el logout.
                  Navigator.of(
                    context,
                  ).pop(); // Esto hace pop de PerfilPage, regresando a MyApp
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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

  // --- Widgets Auxiliares (sin cambios significativos aquí) ---
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
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
                color: Theme.of(context).colorScheme.primary,
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
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
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
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
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
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
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withOpacity(0.03),
    );
  }
}
