import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  BuildContext? _dialogContext;

  Future<void> showLoadingDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            height: 100,
            width: 100,
            child: const CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    if (fkey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      try {
        // Autenticación mediante Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: correocontroller.text,
          password: contracontroller.text,
        );
        User? user = FirebaseAuth.instance.currentUser;
        await user
            ?.reload(); // Recarga el estado del usuario para obtener los datos más recientes
        if (user != null && user.emailVerified) {
        } else {
          // El correo aún no ha sido verificado
          Get.snackbar(
              'Error', 'Por favor, verifica tu correo antes de continuar',
              backgroundColor: Colors.red, colorText: Colors.white);
          Navigator.of(context).pop();
          return;
        }

        // Si el login fue exitoso, obtenemos el UID del usuario autenticado
        String userId = userCredential.user?.uid ?? '';

        // Buscamos al usuario en Firestore
        final QuerySnapshot userQuery = await FirebaseFirestore.instance
            .collection('sellers')
            .where('email', isEqualTo: correocontroller.text)
            .limit(1)
            .get();

        if (userQuery.docs.isEmpty) {
          Navigator.of(context).pop();
          Get.snackbar('Error', 'Usuario no encontrado',
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          final userData = userQuery.docs.first.data() as Map<String, dynamic>;
          if (userData['eneable'] == 1) {
            Get.snackbar('Error', 'Cuenta deshabilitada',
                backgroundColor: Colors.red, colorText: Colors.white);
            Navigator.of(context).pop();
            return;
          }

          Get.snackbar('Éxito', 'Inicio de sesión exitoso',
              backgroundColor: Colors.green, colorText: Colors.white);

          // Crea el objeto Usuario
          Usuario usuario = Usuario(
            id: userQuery.docs.first.id,
            UID: userId,
            name: userData['name'],
            email: userData['email'],
            description: userData['description'],
            instagram: userData['instagram'],
            whatsapp: userData['whatsapp'],
            logo: userData['logo'],
            sede: userData['sede'],
            eneable: userData['eneable'],
          );

          // Obtén el controlador de usuario y guarda el usuario en la base de datos local
          final UsuarioController usuarioController =
              Get.put(UsuarioController());

          await usuarioController.addUsuario(
            id: usuario.id,
            UID: usuario.UID,
            name: usuario.name,
            email: usuario.email,
            description: usuario.description,
            instagram: usuario.instagram,
            whatsapp: usuario.whatsapp,
            logo: usuario.logo,
            sede: usuario.sede,
            eneable: usuario.eneable,
          );
          Navigator.of(context).pop();
          Navigator.pushNamedAndRemoveUntil(
            context,
            MyRoutes.PantallaPrincipal.name,
            (Route<dynamic> route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop();
        String message = 'Error al iniciar sesión';
        if (e.code == 'user-not-found') {
          message = 'Usuario no encontrado';
        } else if (e.code == 'wrong-password') {
          message = 'Contraseña incorrecta';
        }
        Get.snackbar('Error', message,
            backgroundColor: Colors.red, colorText: Colors.white);
        print("Error: $e");
      } catch (e) {
        Navigator.of(context).pop();
        Get.snackbar('Error', 'Ocurrió un error inesperado');
        print("Error: $e");
      }
    } else {
      Get.snackbar('Error', 'Por favor complete los campos correctamente');
    }
  }

  Future<void> _changePassword() async {
    String? email;

    email = await showDialog<String?>(
      context: context,
      builder: (context) {
        String emailInput = '';
        return AlertDialog(
          title: const Text('Ingresa tu correo electrónico'),
          content: TextField(
            onChanged: (value) {
              emailInput = value;
            },
            decoration: const InputDecoration(
              hintText: 'Correo electrónico',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(null), // Cancelar
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () => Navigator.of(context)
                  .pop(emailInput), // Enviar el correo ingresado
            ),
          ],
        );
      },
    );

    if (email != null && email.isNotEmpty) {
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        await auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo enviado'),
          ),
        );
      } catch (e) {
        print("Error al enviar el correo: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un correo válido'),
        ),
      );
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
                  'Bienvenido \nPumita!',
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
                          nombrelabel: 'Correo',
                          hint: 'Ingrese su correo',
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
                              const Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  _changePassword();
                                },
                                child: const Text(
                                  "Restablecer contraseña",
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
