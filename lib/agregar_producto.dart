import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/custom_buttom.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class AgregarProducto extends StatefulWidget {
  const AgregarProducto({Key? key}) : super(key: key);

  @override
  State<AgregarProducto> createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  Usuario? _currentUser;
  List<Usuario> usuarios = [];
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _picker = ImagePicker();
  File? _imagenFile;
  BuildContext? _dialogContext;

  bool _imagenSeleccionada = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _loadUser();
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
            _imagenFile = File(croppedFile.path);
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

  Future<void> _registerProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      try {
        String imageUrl = '';
        if (_imagenFile != null) {
          final storageRef = FirebaseStorage.instance.refFromURL(
              'gs://pumitasemprendedores.appspot.com/products/${DateTime.now().toIso8601String()}');
          final uploadTask = await storageRef.putFile(_imagenFile!);
          imageUrl = await uploadTask.ref.getDownloadURL();
        }
        String combinedText =
            '${_nombreController.text}  ${_descripcionController.text}';
        List<String> keywords = combinedText
            .split(RegExp(r'\s+')) // Dividir en palabras
            .where((word) =>
                word.length > 3) // Filtrar palabras mayores a 3 caracteres
            .map((word) => word.toLowerCase()) // Convertir a minúsculas
            .toList()
            .toSet()
            .toList(); // eliminar duplicados

        await FirebaseFirestore.instance
            .collection('products')
            .doc('vs')
            .collection('vs')
            .add({
          'name': _nombreController.text,
          'category': _categoriaController.text,
          'description': _descripcionController.text,
          'price': double.parse(_precioController.text),
          'image': imageUrl,
          'sellerId': _currentUser?.id,
          "sellerName": _currentUser?.name,
          'fecha': DateTime.now(),
          'keywords': keywords,
          'views': [],
          'images': [imageUrl],
        });

        Get.snackbar('Éxito', 'Producto registrado exitosamente', backgroundColor: Colors.green, colorText: Colors.white);

        _formKey.currentState?.reset();
        setState(() {
          _imagenFile = null;
        });

        Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(
          context,
          MyRoutes.PantallaPrincipal.name,
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        Navigator.of(context).pop();
        Get.snackbar('Error', 'Error al registrar el producto');
        print("Error: $e");
      }
    } else {
      Get.snackbar('Error', 'Por favor complete los campos correctamente', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _loadUser() async {
    try {
      List<Usuario> usuarios;
      usuarios = await DBHelper.queryUsuarios();
      if (usuarios.isNotEmpty) {
        setState(() {
          _currentUser = usuarios.first;
        });
      } else {
        setState(() {
          _currentUser = null;
        });
      }
    } catch (e) {
      print("Error al cargar el usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.50, vertical: 5),
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
                            if (valor.length > 100) {
                              return 'El nombre debe tener menos de 100 caracteres';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Ingrese el nombre del producto',
                          nombrelabel: 'Nombre del producto',
                          icono: Icons.store,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _categoriaController,
                          validator: (valor) {
                            if (_categoriaController.text == "") {
                              _categoriaController.text = "Ropa";
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Ingrese la categoría del producto',
                          nombrelabel: 'Categoría',
                          icono: Icons.category,
                          show: false,
                          items: [
                            'Ropa',
                            'Accesorios',
                            'Alimentos',
                            'Salud y belleza',
                            'Deportes',
                            'Tecnologia',
                            'Mascotas',
                            'Juegos',
                            'Libros',
                            'Arte',
                            'Arreglos y regalos',
                            'Otros'
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _descripcionController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'La descripción es obligatoria';
                            }
                            if (valor.length < 10) {
                              return 'La descripción debe tener al menos 10 caracteres';
                            }
                            if (valor.length > 150) {
                              return 'La descripción debe tener menos de 150 caracteres';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Ingrese la descripción del producto',
                          nombrelabel: 'Descripción',
                          icono: Icons.description,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _precioController,
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'El precio es obligatorio';
                            }
                            if (double.tryParse(valor) == null) {
                              return 'El precio debe ser un número';
                            }
                            if (double.parse(valor) <= 0) {
                              return 'El precio debe ser un numero positivo';
                            }
                            return null;
                          },
                          teclado: TextInputType.number,
                          hint: 'Ingrese el precio del producto',
                          nombrelabel: 'Precio',
                          icono: Icons.attach_money,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: _imagenFile == null
                                ? const Center(
                                    child: Text('Selecciona una imagen'))
                                : Image.file(_imagenFile!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_imagenFile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Debe seleccionar una imagen'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                _registerProduct();
                              }
                            }
                          },
                          label: 'Agregar Producto',
                          textColor: const Color.fromARGB(255, 255, 211, 0),
                          backgroundColor:
                              const Color.fromARGB(255, 33, 46, 127),
                          icon: Icons.add,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
