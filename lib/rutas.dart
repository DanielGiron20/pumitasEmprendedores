import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/pantalla_principal.dart';

enum MyRoutes { PantallaPrincipal }

final Map<String, Widget Function(BuildContext)> routes = {
  MyRoutes.PantallaPrincipal.name: (context) => const PantallaPrincipal()
};
