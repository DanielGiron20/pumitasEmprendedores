import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/rutas.dart';
import 'package:pumitas_emprendedores/wigets/product_card.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  Usuario? _currentUser;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadProducts();
  }

  Future<void> _checkUser() async {
    List<Usuario> usuarios = await DBHelper.queryUsuarios();
    if (usuarios.isNotEmpty) {
      setState(() {
        _currentUser = usuarios.first;
      });
    }
  }

  Future<void> _loadProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection = firestore.collection('products');

    QuerySnapshot snapshot = await productsCollection.get();
    setState(() {
      _products = snapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'description': doc['description'],
          'image': doc['image'],
          'price': doc['price'],
          'category': doc['category'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pumitas emprendedores'),
        actions: [
          _currentUser != null
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, MyRoutes.PerfilPersonal.name);
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(_currentUser!.logo),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(_currentUser!.name),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () {
                    Navigator.pushNamed(context, MyRoutes.Login.name);
                  },
                ),
        ],
      ),
      body: _buildProductList(),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            2, //Aca es si queres que se vea mas de una columna de productos
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          nombre: product['name'],
          descripcion: product['description'],
          imagenUrl: product['image'],
          precio: product['price'],
          onTap: () {},
        );
      },
    );
  }
}
