import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario_controller.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';
import 'package:pumitas_emprendedores/wigets/custom_imputs.dart';

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
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: const Text(
              '¿Estás seguro que desea guardar estos cambios en su perfil?'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 33, 46, 127),
          foregroundColor: const Color.fromARGB(255, 255, 211, 0),
          title: const Text('Editar Perfil'),
        ),
        body: Stack(children: [
          // Fondo pintado personalizado
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _currentUser == null
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _imageFile == null
                            ? CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    NetworkImage(_currentUser!.logo),
                              )
                            : CircleAvatar(
                                radius: 80,
                                backgroundImage: FileImage(_imageFile!),
                              ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image,
                              color: Color.fromARGB(255, 255, 211, 0)),
                          label: const Text(
                            'Seleccionar Imagen',
                            style: TextStyle(
                                color: Color.fromARGB(255, 33, 46, 127)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _userNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre de usuario es obligatorio';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Introduce tu nombre',
                          nombrelabel: 'Nombre de Usuario',
                          icono: Icons.person,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _descripcionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La descripción es obligatoria';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Introduce una descripción',
                          nombrelabel: 'Descripción',
                          icono: Icons.description,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _whatsappController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El whatsapp es obligatorio';
                            }
                            return null;
                          },
                          teclado: TextInputType.phone,
                          hint: 'Introduce tu número de WhatsApp',
                          nombrelabel: 'Whatsapp',
                          icono: Icons.phone,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInputs(
                          controller: _instagramController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El Instagram es obligatorio';
                            }
                            return null;
                          },
                          teclado: TextInputType.text,
                          hint: 'Introduce tu perfil de Instagram',
                          nombrelabel: 'Instagram',
                          icono: Icons.camera_alt,
                          show: false,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 33, 46, 127),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 211, 0),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _saveProfileChanges,
                          child: const Text('Guardar cambios'),
                        ),
                      ],
                    ),
                  ),
          ),
        ]));
  }
}
