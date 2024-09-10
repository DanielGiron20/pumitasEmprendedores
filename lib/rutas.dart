import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/agregar_producto.dart';
import 'package:pumitas_emprendedores/login_page.dart';
import 'package:pumitas_emprendedores/pantalla_principal.dart';
import 'package:pumitas_emprendedores/perfil_personal.dart';
import 'package:pumitas_emprendedores/registro_page.dart';
import 'package:pumitas_emprendedores/producto.dart';


enum MyRoutes {
  PantallaPrincipal,
  Login,
  Registro,
  PerfilPersonal,
  AgregarProducto,
  producto,
}

final Map<String, Widget Function(BuildContext)> routes = {
  MyRoutes.PantallaPrincipal.name: (context) => const PantallaPrincipal(),
  MyRoutes.Login.name: (context) => const LoginPage(),
  MyRoutes.Registro.name: (context) => const RegistroPage(),
  MyRoutes.PerfilPersonal.name: (context) => const PerfilPersonal(),
  MyRoutes.AgregarProducto.name: (context) => const AgregarProducto(),
};
