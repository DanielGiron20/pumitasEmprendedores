import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
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
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 1000,
          maxHeight: 1000,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recortar imagen',
              toolbarColor: const Color.fromARGB(255, 33, 46, 127),
              toolbarWidgetColor: Colors.white,
              activeControlsWidgetColor: const Color.fromARGB(255, 255, 211, 0),
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Recortar imagen',
              aspectRatioLockEnabled: true,
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _logoFile = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al seleccionar o recortar la imagen');
      print("Error al seleccionar o recortar la imagen: $e");
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

/*************  ✨ Codeium Command ⭐  *************/
  /// Registra un nuevo vendedor en la base de datos. Primero verifica que los campos del formulario sean válidos.
  /// Luego, registra el usuario en Firebase Auth y envía un correo de verificación.
  /// Finalmente, guarda la información del vendedor en Firestore.
  ///
/******  5eb3f26a-64e0-4fd4-a408-015f9a01b123  *******/

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
          final storageRef = FirebaseStorage.instance.refFromURL(
              'gs://pumitasemprendedores.appspot.com/logos/${DateTime.now().toIso8601String()}');
          final uploadTask = await storageRef.putFile(_logoFile!);
          logoUrl = await uploadTask.ref.getDownloadURL();
        }

        if (_sedeController.text == "") {
          _sedeController.text = "Valle de sula";
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
          'eneable': 0,
          'reporte': 0,
          'mf': 1,
        });

        // Mostrar un mensaje de éxito
        Get.snackbar('Verificación de correo',
            'Se ha enviado un correo de verificación. Verifica tu correo antes de continuar.',
            backgroundColor: Color.fromARGB(255, 33, 46, 127),
            colorText: Colors.white);

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
      Get.snackbar('Error', 'Por favor complete los campos correctamente',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


void _showTerms(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            titlePadding: EdgeInsets.all(0),
            title: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 57, 160, 212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Términos y Condiciones',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Términos y Condiciones de uso para vendedores\n\n'
                    '1. Aceptación de los Términos: Al descargar, registrarse o utilizar la aplicación "Pumarket", desarrollada con el fin de facilitar el contacto entre vendedores y compradores, usted acepta y se compromete a cumplir estos términos y condiciones. Si no está de acuerdo con alguno de los términos, debe abstenerse de utilizar la aplicación.\n\n'
                    '2. Al registrarse, usted acepta que sus datos proporcionados, incluyendo su contacto de teléfono, cuenta de Instagram (si es proporcionada), serán visibles públicamente para todos los usuarios de la aplicación.\n\n'
                    'Esta información es necesaria para facilitar la comunicación entre vendedores y compradores. No nos hacemos responsables del uso que otros usuarios puedan hacer de esta información fuera de la plataforma.\n\n'
                    '3. Contenido Subido por el Usuario: Al subir contenido, como imágenes o descripciones de productos, usted declara ser el propietario legítimo de dicho contenido y que no infringe los derechos de terceros. Nos reservamos el derecho de eliminar cualquier contenido que consideremos inapropiado o que infrinja estos términos.\n\n'
                    '4. Responsabilidad del Usuario: Usted es el único responsable de la información que comparte en la aplicación y de las interacciones que tenga con otros usuarios. No somos responsables de las negociaciones, transacciones o conflictos que puedan surgir entre usuarios.\n\n'
                    '5. Terminación del Servicio: Nos reservamos el derecho de suspender o eliminar su cuenta si se detecta un uso indebido de la plataforma o si incumple estos términos.\n\n'
                    '6. Spam: La subida de un mismo producto repetidas veces sera visto como spam y sera eliminado.\n\n',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('No acepto'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 34, 174, 226),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Si acepto'),
                onPressed: () {
                  registerSeller();
                },
              ),
            ],
          );
        },
      );
    },
  );
}


void _validateEmail() async {
  // Verificar si el formulario es válido
  if (!(_formKey.currentState?.validate() ?? false)) {
    // Si la validación falla, mostrar un mensaje de error y retornar
    Get.snackbar(
      'Error',
      'Por favor complete los campos correctamente',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return; // Salir de la función si los campos no son válidos
  }

  // Si los campos están bien, entonces proceder con las validaciones del correo y nombre
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
        content: Text('El nombre de usuario ya existe, por favor ingrese otro.'),
        backgroundColor: Colors.red,
      ),
    );
  } else {
    // Si todo está bien, mostrar los términos y condiciones
    _showTerms(context);
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
                            if (valor.length > 20) {
                              return 'El nombre no puede tener más de 20 caracteres';
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
                            if (valor.length > 100) {
                              return 'La descripción no puede tener más de 100 caracteres';
                            }
                            if (valor.length < 10) {
                              return 'La descripción debe tener al menos 10 caracteres';
                            }
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
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El número de WhatsApp es obligatorio';
                            }
                            if (valor.length != 8) {
                              return "El número de WhatsApp debe tener 8 digitos";
                            }
                            return null;
                          },
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
                          nombrelabel: 'Usuario de Instagram',
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
