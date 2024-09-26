import 'package:get/get.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/sede.dart';

class SedeController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    getSedes(); // Carga las sedes cuando el controlador está listo
  }

  var sedeList = <Sede>[].obs; // Lista reactiva de sedes

  // Método para agregar una sede
  Future<void> addSede({
    required String id,
    required String cede,
  }) async {
    try {
      Sede sede = Sede(
        id: id,
        cede: cede,
      );

      // Inserta la sede en la base de datos
      await DBHelper.insertSede(sede);

      // Actualiza la lista de sedes
      getSedes();
    } catch (e) {
      print("Error al agregar la sede: $e");
      // Maneja el error, por ejemplo, mostrando un mensaje al usuario
    }
  }

  void getSedes() async {
    try {
      List<Sede> sedes = await DBHelper.querySedes();
      sedeList.assignAll(sedes);
    } catch (e) {
      print("Error al obtener sedes: $e");
    }
  }

  // Método para eliminar una sede
  Future<void> deleteSede(Sede sede) async {
    try {
      await DBHelper.deleteSede(sede);
      getSedes();
    } catch (e) {
      print("Error al eliminar la sede: $e");
    }
  }

  // Método para actualizar una sede
  Future<void> updateSede(String id, Map<String, dynamic> updates) async {
    try {
      await DBHelper.updateSede(id, updates);
      getSedes();
    } catch (e) {
      print("Error al actualizar la sede: $e");
    }
  }
}
