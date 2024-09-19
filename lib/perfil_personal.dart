import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/Editar_perfil.dart';
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';
import 'package:pumitas_emprendedores/wigets/custom_buttom.dart';

class PerfilPersonal extends StatefulWidget {
  const PerfilPersonal({super.key});

  @override
  _PerfilPersonalState createState() => _PerfilPersonalState();
}

class _PerfilPersonalState extends State<PerfilPersonal> {
  Usuario? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }



  Future<void> _loadUser() async {
    try {
      List<Usuario> usuarios = await DBHelper.queryUsuarios();
      if (usuarios.isNotEmpty) {
        setState(() {
          _currentUser = usuarios.first;
        });
      } else {
        setState(() {
          _currentUser = null;
        });
      }
    } catch (e) {
      print("Error al cargar el usuario: $e");
    }
  }

  Future<void> _logout() async {
    try {
      List<Usuario> usuarios = await DBHelper.queryUsuarios();
      if (usuarios.isNotEmpty) {
        Usuario userToDelete = usuarios.first;
        await DBHelper.deleteUsuario(userToDelete);
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.PantallaPrincipal.name,
          (Route<dynamic> route) => false,
        );
      } else {
        print("No hay usuarios disponibles para eliminar.");
      }
    } catch (e) {
      print("Error al eliminar el usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Personal'),
        centerTitle: true,
      ),
      body: _currentUser == null
          ? Center(
              child: Text(
                'No hay información de usuario disponible.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : Stack(
              children: [
                // Fondo pintado personalizado
                CustomPaint(
                  size: Size.infinite,
                  painter: BackgroundPainter(),
                ),
                // Contenido del perfil
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(_currentUser!.logo),
                                radius: 60,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _currentUser!.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _currentUser!.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.email,
                                  label: 'Email',
                                  value: _currentUser!.email,
                                ),
                                _buildInfoRow(
                                  icon: Icons.location_pin,
                                  label: 'Sede',
                                  value: _currentUser!.sede,
                                ),
                                _buildInfoRow(
                                  icon: FontAwesomeIcons.instagram,
                                  label: 'Instagram',
                                  value: _currentUser!.instagram,
                                ),
                                _buildInfoRow(
                                  icon: FontAwesomeIcons.whatsapp,
                                  label: 'WhatsApp',
                                  value: _currentUser!.whatsapp,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Botón de 'Editar Perfil'
                        CustomButton(
                          label: 'Editar Perfil',
                          backgroundColor:
                              const Color.fromARGB(255, 57, 57, 57),
                          textColor: Colors.white, // Texto blanco
                          icon: Icons.add,
                          onPressed: () {
                          Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) => EditarPerfilPage(),
  ),
);

                          },
                        ),

                        const SizedBox(height: 10),

                        // Botón de 'Agregar Producto'
                        CustomButton(
                          label: 'Agregar Producto',
                          backgroundColor:
                              const Color.fromARGB(255, 57, 57, 57),
                          textColor: Colors.white, // Texto blanco
                          icon: Icons.add,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              MyRoutes.AgregarProducto.name,
                              arguments: {'currentUser': _currentUser},
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        // Botón de 'Ver mis productos'
                        CustomButton(
                          label: 'Ver mis productos',
                          backgroundColor:
                              const Color.fromARGB(255, 57, 57, 57),
                          textColor: Colors.white,
                          icon: Icons.list,
                          onPressed: () {
                            Navigator.pushNamed(
                                context,
                                MyRoutes.MisProductos
                                    .name); // Navega a la página de 'Mis Productos'
                          },
                        ),

                        const SizedBox(height: 10),

                        CustomButton(
                          label: 'Cerrar Sesión',
                          backgroundColor:
                              const Color.fromARGB(255, 57, 57, 57),
                          textColor: Colors.white,
                          icon: Icons.logout,
                          onPressed: _logout, // Función para cerrar sesión
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
