import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/rutas.dart';
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenFile = File(pickedFile.path);
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

  Future<void> _registerProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      showLoadingDialog(context);

      try {
        String imageUrl = '';
        if (_imagenFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('products/${DateTime.now().millisecondsSinceEpoch}.png');
          final uploadTask = await storageRef.putFile(_imagenFile!);
          imageUrl = await uploadTask.ref.getDownloadURL();
        }
        await FirebaseFirestore.instance.collection('products').add({
          'name': _nombreController.text,
          'category': _categoriaController.text,
          'description': _descripcionController.text,
          'price': double.parse(_precioController.text),
          'image': imageUrl,
          'sellerId': _currentUser?.id,
          "sellerName": _currentUser?.name,
        });

        Get.snackbar('Éxito', 'Producto registrado exitosamente');

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
      Get.snackbar('Error', 'Por favor complete los campos correctamente');
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
                  'Agregar Producto',
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
                            if (valor == null || valor.isEmpty) {
                              return 'La categoría es obligatoria';
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
                            'Juguetes o juegos',
                            'Libros',
                            'Arte',
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
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _registerProduct();
                            }
                          },
                          child: const Text('Agregar Producto'),
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
