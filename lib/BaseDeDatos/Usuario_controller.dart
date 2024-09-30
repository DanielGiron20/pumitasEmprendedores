import 'package:get/get.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';

class UsuarioController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    getUsuarios(); // Carga los usuarios cuando el controlador está listo
  }

  var usuarioList = <Usuario>[].obs; // Lista reactiva de usuarios

  // Método para agregar un usuario
  Future<void> addUsuario({
    required String id,
    required String UID,
    required String name,
    required String email,
    required String description,
    required String instagram,
    required String whatsapp,
    required String logo,
    required String sede,
    required int eneable,
  }) async {
    try {
      Usuario usuario = Usuario(
        id: id,
        UID: UID,
        name: name,
        email: email,
        description: description,
        instagram: instagram,
        whatsapp: whatsapp,
        logo: logo,
        sede: sede,
        eneable: eneable,
      );

      // Inserta el usuario en la base de datos
      await DBHelper.insertUsuario(usuario);

      // Actualiza la lista de usuarios
      getUsuarios();
    } catch (e) {
      print("Error al agregar el usuario: $e");
      // Maneja el error, por ejemplo, mostrando un mensaje al usuario
    }
  }

  // Método para obtener todos los usuarios
  void getUsuarios() async {
    try {
      List<Usuario> usuarios = await DBHelper.queryUsuarios();
      usuarioList
          .assignAll(usuarios); // Asigna directamente la lista de usuarios
    } catch (e) {
      print("Error al obtener usuarios: $e");
      // Maneja el error, por ejemplo, mostrando un mensaje al usuario
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUsuario(Usuario usuario) async {
    try {
      await DBHelper.deleteUsuario(
          usuario); // Elimina el usuario de la base de datos
      getUsuarios(); // Actualiza la lista de usuarios después de eliminar
    } catch (e) {
      print("Error al eliminar el usuario: $e");
      // Maneja el error, por ejemplo, mostrando un mensaje al usuario
    }
  }

  // Método para actualizar un usuario
  Future<void> updateUsuario(String id, Map<String, dynamic> updates) async {
    try {
      await DBHelper.updateUsuario(
          id, updates); // Actualiza el usuario con los campos proporcionados
      getUsuarios(); // Actualiza la lista de usuarios después de la actualización
    } catch (e) {
      print("Error al actualizar el usuario: $e");
      // Maneja el error, por ejemplo, mostrando un mensaje al usuario
    }
  }
}
