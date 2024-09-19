import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/Usuario.dart';
import 'package:pumitas_emprendedores/Editar_producto.dart';
import 'package:pumitas_emprendedores/agregar_producto.dart';
import 'package:pumitas_emprendedores/login_page.dart';
import 'package:pumitas_emprendedores/mis_productos.dart';
import 'package:pumitas_emprendedores/pantalla_principal.dart';
import 'package:pumitas_emprendedores/perfil_personal.dart';
import 'package:pumitas_emprendedores/registro_page.dart';
import 'package:pumitas_emprendedores/Editar_perfil.dart';


enum MyRoutes {
  PantallaPrincipal,
  Login,
  Registro,
  PerfilPersonal,
  AgregarProducto,
  MisProductos,
  EditarProducto,
  Editar_perfil,
}

final Map<String, Widget Function(BuildContext)> routes = {
  MyRoutes.PantallaPrincipal.name: (context) => const PantallaPrincipal(),
  MyRoutes.Login.name: (context) => const LoginPage(),
  MyRoutes.Registro.name: (context) => const RegistroPage(),
  MyRoutes.PerfilPersonal.name: (context) => const PerfilPersonal(),
  MyRoutes.AgregarProducto.name: (context) => const AgregarProducto(),
  MyRoutes.MisProductos.name: (context) => const MisProductos(),
  MyRoutes.EditarProducto.name: (context) => const EditarProductosPage(sellerId: '', description: '', name: '', image: '', price: 0, category: '',),
};
