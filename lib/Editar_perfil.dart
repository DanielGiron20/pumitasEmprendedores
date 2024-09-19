import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario_controller.dart';

class EditarPerfilPage extends StatefulWidget {
  EditarPerfilPage({Key? key}) : super(key: key);

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  late TextEditingController _descripcionController;
  File? _imageFile;
  Usuario? _currentUser; // Mueve _currentUser aquí

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      List<Usuario> usuarios = await DBHelper.queryUsuarios();
      if (usuarios.isNotEmpty) {
        Usuario userToDelete = usuarios.first;
        await DBHelper.deleteUsuario(userToDelete);
      } else {
        print("No hay usuarios disponibles para eliminar.");
      }
    } catch (e) {
      print("Error al eliminar el usuario: $e");
    }
  }

  Future<void> _checkUser() async {
    List<Usuario> usuarios = await DBHelper.queryUsuarios();
    if (usuarios.isNotEmpty) {
      setState(() {
        _currentUser = usuarios.first;
        _userNameController = TextEditingController(text: _currentUser?.name);
        _whatsappController =
            TextEditingController(text: _currentUser?.whatsapp);
        _instagramController =
            TextEditingController(text: _currentUser?.instagram);
        _descripcionController =
            TextEditingController(text: _currentUser?.description);
      });
    }
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

        String? newImageUrl = _currentUser?.logo;
        if (_imageFile != null) {
          newImageUrl = await _uploadImage(_imageFile!);
        }

        // Actualiza en Firebase
        await firestore.collection('sellers').doc(_currentUser!.id).update({
          'name': _userNameController.text,
          'whatsapp': _whatsappController.text,
          'logo': newImageUrl,
          'instagram': _instagramController.text,
          'description': _descripcionController.text,
        });

        // Actualiza en la base de datos local usando el UsuarioController
        final usuarioController = UsuarioController();
        await usuarioController.updateUsuario(_currentUser!.id, {
          'name': _userNameController.text,
          'email': _currentUser!.email.toString(),
          'description': _descripcionController.text,
          'instagram': _instagramController.text,
          'whatsapp': _whatsappController.text,
          'password': _currentUser!.password.toString(),
          'logo': newImageUrl.toString(),
          'sede': _currentUser!.sede.toString(),
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
        child: _currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _imageFile == null
                        ? Image.network(_currentUser!.logo, height: 200)
                        : Image.file(_imageFile!, height: 200),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Seleccionar Imagen'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _userNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nombre de Usuario'),
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
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es obligatoria';
                        }
                        return null;
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _instagramController,
                      decoration: const InputDecoration(labelText: 'Instagram'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El instagram es obligatorio';
                        }
                        return null;
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