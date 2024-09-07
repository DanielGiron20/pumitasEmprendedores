import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  File? _logoFile;

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

  Future<void> registerSeller() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        String logoUrl = '';
        if (_logoFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('logos/${DateTime.now().millisecondsSinceEpoch}.png');
          final uploadTask = await storageRef.putFile(_logoFile!);
          logoUrl = await uploadTask.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('sellers').add({
          'name': _nombreController.text,
          'email': _correoController.text,
          'description': _descripcionController.text,
          'instagram': _instagramController.text,
          'whatsapp': _whatsappController.text,
          'password': _contrasenaController.text, 
          'logo': logoUrl,
        });

        Get.snackbar('Éxito', 'Vendedor registrado exitosamente');

        _formKey.currentState?.reset();
        setState(() {
          _logoFile = null;
        });
      } catch (e) {
        Get.snackbar('Error', 'Error al registrar el vendedor');
      }
    } else {
      print("Formulario no válido");
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de vendedor',
                            hintText: 'Ingrese el nombre de vendedor',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El nombre es obligatorio';
                            }
                            if (valor.length < 3) {
                              return 'El nombre debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _correoController,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            hintText: 'Ingrese su correo electrónico',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El correo es obligatorio';
                            }
                            if (!GetUtils.isEmail(valor)) {
                              return 'El correo no es válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            hintText: 'Ingrese una descripción del negocio',
                            prefixIcon: const Icon(Icons.description),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La descripción es obligatoria';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _whatsappController,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp',
                            hintText: 'Ingrese el número de WhatsApp',
                            prefixIcon: const FaIcon(FontAwesomeIcons.whatsapp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _instagramController,
                          decoration: InputDecoration(
                            labelText: 'Instagram',
                            hintText: 'Ingrese el enlace de Instagram',
                            prefixIcon: const FaIcon(FontAwesomeIcons.instagram),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 20),
                        // Campo de contraseña
                        TextFormField(
                          controller: _contrasenaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            hintText: 'Ingrese su contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La contraseña es obligatoria';
                            }
                            if (valor.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: _logoFile == null
                                ? const Center(child: Text('Selecciona una imagen'))
                                : Image.file(_logoFile!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: registerSeller,
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
