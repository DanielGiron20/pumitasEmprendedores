import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditarPerfilPage extends StatefulWidget {
  final String userName;
  final String whatsapp;
  final String imageUrl;
  final String instagram;
  final String descripcion;
  final String id;

  const EditarPerfilPage({
    required this.userName,
    required this.whatsapp,
    required this.imageUrl,
    required this.instagram,
    required this.descripcion,
    required this.id,
    Key? key, 
  }) : super(key: key);

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _descripcionController;
  File? _imageFile; // Para almacenar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userName);
    _whatsappController = TextEditingController(text: widget.whatsapp);
    _instagramController = TextEditingController(text: widget.instagram);
    _descripcionController = TextEditingController(text: widget.descripcion);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _descripcionController.dispose();
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
          .child('profile_images/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  Future<void> _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        String? newImageUrl = widget.imageUrl;
        if (_imageFile != null) {
          newImageUrl = await _uploadImage(_imageFile!);
        }
        await firestore.collection('sellers').doc(widget.id).update({
          'name': _userNameController.text,
          'whatsapp': _whatsappController.text,
          'logo': newImageUrl,
          'instagram': _instagramController.text,
          'description': _descripcionController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              _imageFile == null
                  ? Image.network(widget.imageUrl, height: 200)
                  : Image.file(_imageFile!, height: 200),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre de usuario es obligatorio';
                  }
                  return null;
                },
              ),
            
 const SizedBox(height: 20),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El instagram es obligatorio';
                  }
                },
              ),

               const SizedBox(height: 20),
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(labelText: 'Whatsapp'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El whatsapp es obligatorio';
                  }
                },
              ),


const SizedBox(height: 20),
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(labelText: 'Descripcion'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria'; 
                  }
                },
              ),



              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfileChanges,
                child: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
