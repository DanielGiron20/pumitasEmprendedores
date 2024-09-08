import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/rutas.dart';

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
      ),
      body: _currentUser == null
          ? Center(child: Text('No hay información de usuario disponible.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_currentUser!.logo),
                    radius: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nombre: ${_currentUser!.name}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${_currentUser!.email}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Descripción: ${_currentUser!.description}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Instagram: ${_currentUser!.instagram}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'WhatsApp: ${_currentUser!.whatsapp}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sede: ${_currentUser!.sede}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          MyRoutes.AgregarProducto.name,
                          arguments: {'currentUser': _currentUser},
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Agregar producto'), Icon(Icons.add)],
                      )),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _logout,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Cerrar Sesión'), Icon(Icons.logout)],
                      ))
                ],
              ),
            ),
    );
  }
}
