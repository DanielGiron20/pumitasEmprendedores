import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/mis_productos.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

class EditarProductosPage extends StatefulWidget {
  final String name;
  final String description;
  final String image;
  final double price;
  final String category;
  final String sellerId;
  // Añadido para identificar el producto

  const EditarProductosPage({
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
    required this.sellerId,
    // Inicializar en el constructor
    Key? key,
  }) : super(key: key);

  @override
  _EditarProductosPageState createState() => _EditarProductosPageState();
}

class _EditarProductosPageState extends State<EditarProductosPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  String? _selectedCategory;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price.toString());
    _categoryController = TextEditingController(text: widget.category);
    _selectedCategory = widget.category;

    print(widget.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
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
            _imageFile = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      print("Error al seleccionar o recortar la imagen: $e");
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(
          'gs://pumitasemprendedores.appspot.com/products/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: const Text('¿Estás seguro que deseas editar este producto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      if (_formKey.currentState!.validate()) {
        try {
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          String? newImageUrl = widget.image;
          String? previousImageUrl = widget.image;

          if (_imageFile != null) {
            newImageUrl = await _uploadImage(_imageFile!);
          }

          QuerySnapshot productQuery = await firestore
              .collection('products')
              .doc('vs products')
              .collection('vs')
              .where('name', isEqualTo: widget.name)
              .where('description', isEqualTo: widget.description)
              .where('price', isEqualTo: widget.price)
              .where('category', isEqualTo: widget.category)
              .get();

          if (productQuery.docs.isNotEmpty) {
            String documentId = productQuery.docs.first.id;

            await firestore
                .collection('products')
                .doc('vs products')
                .collection('vs')
                .doc(documentId)
                .update({
              'name': _nameController.text,
              'description': _descriptionController.text,
              'price': double.parse(_priceController.text),
              'category': _selectedCategory,
              'image': newImageUrl,
              'fecha': DateTime.now(),
            });

            if (_imageFile != null &&
                previousImageUrl != null &&
                previousImageUrl != newImageUrl) {
              await FirebaseStorage.instance
                  .refFromURL(previousImageUrl)
                  .delete();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto actualizado con éxito')),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MisProductos(),
              ),
            );
          } else {
            print("No se encontro el producto");
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el producto: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        title: const Text('Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _imageFile == null
                  ? Image.network(widget.image, height: 200)
                  : Image.file(_imageFile!, height: 200),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              CustomInputs(
                controller: _nameController,
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
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: _selectedCategory,
                  icon: Icon(Icons.category),
                ),
                items: [
                  'Ropa',
                  'Accesorios',
                  'Alimentos',
                  'Salud y belleza',
                  'Arreglos y regalos',
                  'Deportes',
                  'Tecnologia',
                  'Mascotas',
                  'Juegos',
                  'Libros',
                  'Arte',
                  'Otros'
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'La categoría es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomInputs(
                controller: _descriptionController,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  if (valor.length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  if (valor.length > 100) {
                    return 'La descripción debe tener menos de 100 caracteres';
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
                controller: _priceController,
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  if (double.tryParse(valor) == null) {
                    return 'El precio debe ser un número';
                  }
                  if (double.parse(valor) <= 0) {
                    return 'El precio debe ser positivo';
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
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
