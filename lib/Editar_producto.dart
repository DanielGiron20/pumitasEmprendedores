import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/mis_productos.dart';

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
  File? _imageFile; // Archivo de imagen

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price.toString());
    _categoryController = TextEditingController(text: widget.category);
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().toIso8601String()}');
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
  if (_formKey.currentState!.validate()) {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String? newImageUrl = widget.image; 

      if (_imageFile != null) {
        newImageUrl = await _uploadImage(_imageFile!);
      }

      QuerySnapshot productQuery = await firestore
          .collection('products')
          .where('name', isEqualTo: widget.name)
          .where('description', isEqualTo: widget.description)
          .where('price', isEqualTo: widget.price)
          .where('category', isEqualTo: widget.category)
          .get();

      
      if (productQuery.docs.isNotEmpty) {
       
        String documentId = productQuery.docs.first.id;
print("Llego aca");
        await firestore.collection('products').doc(documentId).update({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'category': _categoryController.text,
          'image': newImageUrl, 

        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado con éxito')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MisProductos(),
          ),
        );
      }
      else{
        print("No se encontro el producto");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el producto: $e')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Muestra la imagen actual o la imagen seleccionada
              _imageFile == null
                  ? Image.network(widget.image, height: 200)
                  : Image.file(_imageFile!, height: 200),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción no puede estar vacía';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El precio no puede estar vacío';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un valor válido para el precio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La categoría no puede estar vacía';
                  }
                  return null;
                },
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
