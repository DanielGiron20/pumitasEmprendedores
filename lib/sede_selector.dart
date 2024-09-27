import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Necesario para usar GetX
import 'package:pumitas_emprendedores/BaseDeDatos/sede_controller.dart'; // Importa el controlador de Sede
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/custom_buttom.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class SedeSelector extends StatefulWidget {
  const SedeSelector({super.key});

  @override
  _SedeSelectorState createState() => _SedeSelectorState();
}

class _SedeSelectorState extends State<SedeSelector> {
  final TextEditingController _sedeController = TextEditingController();
  final SedeController _sedeControllerDB =
      Get.put(SedeController()); // Instancia el controlador de Sede

  @override
  void dispose() {
    _sedeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 33, 46, 127),
          foregroundColor: const Color.fromARGB(255, 255, 211, 0),
          title: const Text('Elije Una sede'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomInputs(
                controller: _sedeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione una opción';
                  }
                  return null;
                },
                teclado: TextInputType.text,
                hint: 'Elegir Centro',
                nombrelabel: 'Sede',
                icono: Icons.location_city,
                show: false,
                items: const ['Valle de Sula', 'Ciudad Universitaria', 'CURLA'],
              ),
              SizedBox(width: 10, height: 20),
              CustomButton(
                label: 'Elige el Centro Regional',
                backgroundColor: const Color.fromARGB(255, 33, 46, 127),
                textColor: const Color.fromARGB(255, 255, 211, 0),
                icon: Icons.save,
                onPressed: () {
                  if (_sedeController.text.isNotEmpty) {
                    _sedeControllerDB.addSede(
                      id: DateTime.now().toString(),
                      cede: _sedeController.text,
                    );
                    Get.snackbar('Éxito', 'Sede registrada exitosamente');
                    Navigator.pushReplacementNamed(
                        context, MyRoutes.PantallaPrincipal.name);
                  } else {
                    Get.snackbar('Error', 'Por favor, selecciona una sede');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
