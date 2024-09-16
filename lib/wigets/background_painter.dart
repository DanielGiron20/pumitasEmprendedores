import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    //triangulo azul
    /*
    paint.color = const Color.fromARGB(255, 33, 46, 127);
    var path = Path();
    path.moveTo(0, size.height * 0.75); // Comienza a 3/4 de la pantalla
    path.lineTo(size.width, size.height); // Esquina inferior derecha
    path.lineTo(0, size.height); // Esquina inferior izquierda
    path.close();
    canvas.drawPath(path, paint);
    */
    paint.color = const Color.fromARGB(255, 33, 46, 127);
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    //triangulo amarillo
    paint.color = const Color.fromARGB(255, 255, 211, 0);
    path = Path();
    path.moveTo(0, size.height); // Esquina inferior izquierda
    path.lineTo(
        size.width, size.height * 0.75); // Comienza donde termina el azul
    path.lineTo(size.width, size.height); // Esquina inferior derecha
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
