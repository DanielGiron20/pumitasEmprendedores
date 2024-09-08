import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableName = "usuarios";

  static Future<void> initDB() async {
    if (_db != null) return;

    try {
      String _path = await getDatabasesPath() + 'usuarios.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("Creando nueva tabla de usuarios");
          return db.execute(
            "CREATE TABLE $_tableName("
            "id TEXT PRIMARY KEY,"
            "name TEXT,"
            "email TEXT,"
            "description TEXT,"
            "instagram TEXT,"
            "whatsapp TEXT,"
            "password TEXT,"
            "logo TEXT,"
            "sede TEXT)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // Inserta un nuevo usuario
  static Future<int> insertUsuario(Usuario usuario) async {
    print("Insertando usuario");
    return await _db?.insert(_tableName, usuario.toJson()) ?? 1;
  }

  // Consulta todos los usuarios
  static Future<List<Usuario>> queryUsuarios() async {
    final List<Map<String, dynamic>> usuariosMapList =
        await _db!.query(_tableName);
    return usuariosMapList
        .map((usuarioMap) => Usuario.fromJson(usuarioMap))
        .toList();
  }

  // Elimina un usuario
  static Future<int> deleteUsuario(Usuario usuario) async {
    return await _db!
        .delete(_tableName, where: 'id = ?', whereArgs: [usuario.id]);
  }

  // Actualiza un usuario con campos específicos
  static Future<int> updateUsuario(
      String id, Map<String, dynamic> updates) async {
    return await _db!.update(
      _tableName,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
