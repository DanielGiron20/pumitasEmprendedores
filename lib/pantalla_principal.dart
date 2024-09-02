import 'package:flutter/material.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pumitas emprendedores',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pumitas emprendedores'),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.search, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }
}
