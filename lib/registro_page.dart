import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _picker = ImagePicker();
  final _sedeController = TextEditingController();
  File? _logoFile;
  BuildContext? _dialogContext;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _descripcionController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

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

  Future<void> registerSeller() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        showLoadingDialog(context);

        // Registrar el usuario en Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _correoController.text,
          password: _contrasenaController.text,
        );

        // Enviar el correo de verificación
        await userCredential.user!.sendEmailVerification();

        String logoUrl = '';
        if (_logoFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('logos/${DateTime.now().millisecondsSinceEpoch}.png');
          final uploadTask = await storageRef.putFile(_logoFile!);
          logoUrl = await uploadTask.ref.getDownloadURL();
        }

        // Guardar información del vendedor en Firestore
        await FirebaseFirestore.instance.collection('sellers').add({
          'uid': userCredential.user!.uid,
          'name': _nombreController.text,
          'email': _correoController.text,
          'description': _descripcionController.text,
          'instagram': _instagramController.text,
          'whatsapp': _whatsappController.text,
          'logo': logoUrl,
          'sede': _sedeController.text,
        });

        // Mostrar un mensaje de éxito
        Get.snackbar('Verificación de correo',
            'Se ha enviado un correo de verificación. Verifica tu correo antes de continuar.');

        // Restablecer el formulario
        _formKey.currentState?.reset();
        setState(() {
          _logoFile = null;
        });

        Navigator.of(context).pop();
        Navigator.pop(context);
      } catch (e) {
        Navigator.of(context).pop();
        Get.snackbar('Error', 'Error al registrar el vendedor');
        print("Error: $e");
      }
    } else {
      Get.snackbar('Error', 'Por favor complete los campos correctamente');
    }
  }

  /*Future<void> registerSeller() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);
      final QuerySnapshot nameQuery = await FirebaseFirestore.instance
          .collection('sellers')
          .where('name', isEqualTo: _nombreController.text)
          .get();

      if (nameQuery.docs.isNotEmpty) {
        Navigator.of(context).pop();
        Get.snackbar('Error', 'Ese Nombre de usuario ya existe');
      } else {
        try {
          // Registrar el usuario en Firebase Auth
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _correoController.text,
            password: _contrasenaController.text,
          );

          // Enviar el correo de verificación
          await userCredential.user!.sendEmailVerification();

          String logoUrl = '';
          if (_logoFile != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('logos/${DateTime.now().millisecondsSinceEpoch}.png');
            final uploadTask = await storageRef.putFile(_logoFile!);
            logoUrl = await uploadTask.ref.getDownloadURL();
          }

          DocumentReference sellerRef =
              await FirebaseFirestore.instance.collection('sellers').add({
            'uid': userCredential.user!.uid,
            'name': _nombreController.text,
            'email': _correoController.text,
            'description': _descripcionController.text,
            'instagram': _instagramController.text,
            'whatsapp': _whatsappController.text,
            'logo': logoUrl,
            'sede': _sedeController.text,
          });

          // Mostrar un mensaje indicando que el usuario debe verificar su correo
          Get.snackbar('Verificación de correo',
              'Hemos enviado un correo de verificación a tu dirección de correo. Por favor, verifica tu correo antes de continuar.');

          // Redirigir o esperar a que verifique su correo
          _formKey.currentState?.reset();
          setState(() {
            _logoFile = null;
          });

          Navigator.of(context).pop();
          Navigator.pop(context);
        } catch (e) {
          Navigator.of(context).pop();
          Get.snackbar('Error', 'Error al registrar el vendedor');
          print("Error: $e");
        }
      }
    } else {
      Get.snackbar('Error', 'Por favor complete los campos correctamente');
    }
  }*/

  void _validateEmail() async {
    String email = _correoController.text.trim();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .where('email', isEqualTo: email)
        .get();

    String name = _nombreController.text.trim();
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('sellers')
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El correo ya existe, por favor ingrese otro.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (querySnapshot2.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El nombre de usuario ya existe, por favor ingrese otro.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Si todo es correcto, se procede a registrar
      registerSeller();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 300,
              width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomInputs(
                          controller: _nombreController,
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
                          hint: 'Ingrese el nombre de vendedor',
                          nombrelabel: 'Nombre de vendedor',
                          icono: Icons.person,
                          show: false, // No es campo de contraseña
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _correoController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            if (!GetUtils.isEmail(valor)) {
                              return 'El correo no es válido';
                            }
                            if (!valor.endsWith('@unah.hn') &&
                                !valor.endsWith('@unah.edu.hn')) {
                              return 'El correo debe ser un correo institucional de la UNAH';
                            }
                            return null;
                          },
                          teclado: TextInputType.emailAddress,
                          hint: 'Ingrese su correo electrónico',
                          nombrelabel: 'Correo electrónico',
                          icono: Icons.email,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _descripcionController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La descripción es obligatoria';
                            }
                            if (valor.length < 10) {}
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Ingrese una descripción del negocio',
                          nombrelabel: 'Descripción',
                          icono: Icons.description,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _whatsappController,
                          validator: null,
                          teclado: TextInputType.phone,
                          hint: 'Ingrese el número de WhatsApp',
                          nombrelabel: 'WhatsApp',
                          icono: FontAwesomeIcons.whatsapp,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _instagramController,
                          validator: null, // No hay validación específica
                          teclado: TextInputType.url,
                          hint: 'Ingrese el enlace de Instagram',
                          nombrelabel: 'Instagram',
                          icono: FontAwesomeIcons.instagram,
                          show: false,
                        ),
                        const SizedBox(height: 20),
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
                          items: [
                            'Valle de Sula',
                            'Ciudad Universitaria',
                            'CURLA'
                          ],
                        ),
                        const SizedBox(height: 20),
                        PasswordInput(
                          controller: _contrasenaController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            if (valor.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                          nombrelabel: 'Contraseña',
                          hint: 'Ingrese su contraseña',
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: _logoFile == null
                                ? const Center(
                                    child: Text('Selecciona una imagen'))
                                : Image.file(_logoFile!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _validateEmail,
                          child: const Text('Registrar'),
                        ),
                        const SizedBox(height: 20),
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
