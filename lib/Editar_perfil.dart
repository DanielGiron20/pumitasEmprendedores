import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
  BuildContext? _dialogContext;
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
    try {
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
    } catch (e) {}
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
          'gs://pumitasemprendedores.appspot.com/logos/${DateTime.now().toIso8601String()}');
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
    bool confirmSave = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: const Text(
              '¿Estás seguro que deseas guardar estos cambios en tu perfil?'),
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

    if (confirmSave == true) {
      if (_formKey.currentState!.validate()) {
        try {
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Guardar la URL de la imagen de perfil anterior
          String? previousImageUrl = _currentUser?.logo;

          // Subir nueva imagen si existe
          String? newImageUrl = _currentUser?.logo;
          if (_imageFile != null) {
            newImageUrl = await _uploadImage(_imageFile!);
          }

          // Actualizar datos en Firebase
          await firestore.collection('sellers').doc(_currentUser!.id).update({
            'name': _userNameController.text,
            'whatsapp': _whatsappController.text,
            'logo': newImageUrl,
            'instagram': _instagramController.text,
            'description': _descripcionController.text,
          });

          // Si se subió una nueva imagen y la anterior existe, eliminar la imagen anterior
          if (_imageFile != null &&
              previousImageUrl != null &&
              previousImageUrl != newImageUrl) {
            await FirebaseStorage.instance
                .refFromURL(previousImageUrl)
                .delete();
          }

          // Actualizar la base de datos local usando el UsuarioController
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

          // Cerrar la pantalla después de guardar los cambios
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
                            if (value.length < 3) {
                              return 'El nombre de usuario debe tener al menos 3 caracteres';
                            }
                            if (value.length > 20) {
                              return 'El nombre de usuario no puede tener más de 20 caracteres';
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
                            if (value.length < 10) {
                              return 'La descripción debe tener al menos 10 caracteres';
                            }
                            if (value.length > 100) {
                              return 'La descripción no puede tener más de 100 caracteres';
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
