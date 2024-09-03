import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final contraseniaController = TextEditingController();
  final confirmcontraController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 900,
              width: 600,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 2, 0, 97),
                  Color.fromARGB(255, 0, 1, 42),
                ]),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Crea tu \ncuenta!',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                height: 690,
                width: 600,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 18.0, right: 18, top: 15),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomInputs(
                          show: false,
                          controller: nombreController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (valor.length < 3) {
                              return 'El nombre debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          nombrelabel: 'Nombre',
                          hint: 'Ingrese su Nombre',
                          icono: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          show: false,
                          controller: correoController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            if (!GetUtils.isEmail(valor)) {
                              return 'El correo no es valido';
                            }
                            return null;
                          },
                          teclado: TextInputType.emailAddress,
                          nombrelabel: 'Correo',
                          hint: 'Ingrese su correo',
                          icono: Icons.email,
                        ),
                        const SizedBox(height: 20),
                        PasswordInput(
                          nombrelabel: 'Contraseña',
                          hint: 'Ingrese su contraseña',
                          controller: contraseniaController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (valor.length < 8) {
                              return 'La contraseña debe tener al menos 8 caracteres';
                            }
                            if (!valor.contains(RegExp(r'[A-Z]')) ||
                                !valor.contains(RegExp(r'[!@#\$&*~_&-]'))) {
                              return 'La contraseña debe contener una mayúscula y un carácter especial';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        PasswordInput(
                          nombrelabel: 'Confirmar Contraseña',
                          hint: 'Confirma tu Contraseña',
                          controller: confirmcontraController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (valor != contraseniaController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 55,
                          width: 300,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            gradient: LinearGradient(colors: [
                              Color.fromARGB(255, 2, 0, 97),
                              Color.fromARGB(255, 0, 1, 42),
                            ]),
                          ),
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
