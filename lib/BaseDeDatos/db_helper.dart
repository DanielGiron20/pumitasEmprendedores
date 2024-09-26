import 'package:pumitas_emprendedores/BaseDeDatos/sede.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 1;
  static final String _tableNameUsuarios = "usuarios";
  static final String _tableNameSedes = "sedes";

  // Inicializa la base de datos
  static Future<void> initDB() async {
    if (_db != null) return;

    try {
      String _path = await getDatabasesPath() + 'pumitas.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) {
          print("Creando nuevas tablas de usuarios y sedes");

          // Tabla de Usuarios
          db.execute(
            "CREATE TABLE $_tableNameUsuarios("
            "id TEXT PRIMARY KEY,"
            "name TEXT,"
            "email TEXT,"
            "description TEXT,"
            "instagram TEXT,"
            "whatsapp TEXT,"
            "logo TEXT,"
            "sede TEXT)",
          );

          // Tabla de Sedes
          db.execute(
            "CREATE TABLE $_tableNameSedes("
            "id TEXT PRIMARY KEY,"
            "cede TEXT)",
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // Métodos para Usuarios

  // Inserta un nuevo usuario
  static Future<int> insertUsuario(Usuario usuario) async {
    print("Insertando usuario");
    return await _db?.insert(_tableNameUsuarios, usuario.toJson()) ?? 1;
  }

  // Consulta todos los usuarios
  static Future<List<Usuario>> queryUsuarios() async {
    final List<Map<String, dynamic>> usuariosMapList =
        await _db!.query(_tableNameUsuarios);
    return usuariosMapList
        .map((usuarioMap) => Usuario.fromJson(usuarioMap))
        .toList();
  }

  // Elimina un usuario
  static Future<int> deleteUsuario(Usuario usuario) async {
    return await _db!.delete(
      _tableNameUsuarios,
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Actualiza un usuario
  static Future<int> updateUsuario(
      String id, Map<String, dynamic> updates) async {
    return await _db!.update(
      _tableNameUsuarios,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para Sedes

  // Inserta una nueva sede
  static Future<int> insertSede(Sede sede) async {
    print("Insertando sede");
    return await _db?.insert(_tableNameSedes, sede.toJson()) ?? 1;
  }

  // Consulta todas las sedes
  static Future<List<Sede>> querySedes() async {
    final List<Map<String, dynamic>> sedesMapList =
        await _db!.query(_tableNameSedes);
    return sedesMapList.map((sedeMap) => Sede.fromJson(sedeMap)).toList();
  }

  // Elimina una sede
  static Future<int> deleteSede(Sede sede) async {
    return await _db!.delete(
      _tableNameSedes,
      where: 'id = ?',
      whereArgs: [sede.id],
    );
  }

  // Actualiza una sede
  static Future<int> updateSede(String id, Map<String, dynamic> updates) async {
    return await _db!.update(
      _tableNameSedes,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
