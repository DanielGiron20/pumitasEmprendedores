import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario_controller.dart';
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final pinController = TextEditingController();
  final correocontroller = TextEditingController();
  final contracontroller = TextEditingController();
  final GlobalKey<FormState> fkey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (fkey.currentState?.validate() ?? false) {
      try {
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('sellers')
            .where('email', isEqualTo: correocontroller.text)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          Get.snackbar('Error', 'Usuario no encontrado');
        } else {
          final userData = userQuery.docs.first.data() as Map<String, dynamic>;
          if (userData['password'] == contracontroller.text) {
            Get.snackbar('Éxito', 'Inicio de sesión exitoso');

            String userId = userQuery.docs.first.id;

            final UsuarioController usuarioController =
                Get.put(UsuarioController());

            Usuario usuario = Usuario(
              id: userId,
              name: userData['name'],
              email: userData['email'],
              description: userData['description'],
              instagram: userData['instagram'],
              whatsapp: userData['whatsapp'],
              password: userData['password'],
              logo: userData['logo'],
              sede: userData['sede'],
            );

            await usuarioController.addUsuario(
              id: usuario.id,
              name: usuario.name,
              email: usuario.email,
              description: usuario.description,
              instagram: usuario.instagram,
              whatsapp: usuario.whatsapp,
              password: usuario.password,
              logo: usuario.logo,
              sede: usuario.sede,
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              MyRoutes.PantallaPrincipal.name,
              (Route<dynamic> route) => false,
            );
          } else {
            Get.snackbar('Error', 'Contraseña incorrecta');
          }
        }
      } catch (e) {
        Get.snackbar('Error', 'Error al iniciar sesión');
      }
    } else {
      Get.snackbar('Error', 'Por favor complete los campos correctamente');
    }
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
              ])),
              child: const Padding(
                padding: EdgeInsets.only(top: 60.0, left: 22),
                child: Text(
                  'Bienvenido \ningresa!',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Form(
                key: fkey,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Colors.white,
                  ),
                  height: 690,
                  width: 600,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomInputs(
                          show: false,
                          nombrelabel: 'Usuario',
                          hint: 'Ingrese su nombre de vendedor',
                          teclado: TextInputType.emailAddress,
                          controller: correocontroller,
                          icono: Icons.check,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        PasswordInput(
                          nombrelabel: 'Password',
                          hint: 'Ingrese su contraseña',
                          controller: contracontroller,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 55,
                          width: 300,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              gradient: LinearGradient(colors: [
                                Color.fromARGB(255, 2, 0, 97),
                                Color.fromARGB(255, 0, 1, 42),
                              ])),
                          child: OutlinedButton(
                            onPressed: _login,
                            child: const Text(
                              'Ingresar',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 150,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "¿No tienes una cuenta?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, MyRoutes.Registro.name);
                                },
                                child: const Text(
                                  "Regístrate",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        )
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
