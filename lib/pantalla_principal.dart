import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/rutas.dart';

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
        crossAxisCount: 1, //Aca es si queres que se vea mas de una columna de productos
        childAspectRatio: 1.1, // y aca el alto de los cards, no se poruue aca menos es mas jajaja
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductCard(
          nombre: product['name'],
          descripcion: product['description'],
          imagenUrl: product['image'],
          precio: product['price'],
          categoria: product['category'], 
        );
      },
    );
  }
}

//clase del card
class ProductCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final double precio;
  final String categoria;

  const ProductCard({
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.precio,
    required this.categoria,
    Key? key,
  }) : super(key: key);


// No te miento, esta apariencia se la pedi a chatsitoGPT
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              imagenUrl,
              height: 200, 
              width: double.infinity,
              fit: BoxFit.cover, 
            ),
          ),
          const SizedBox(height: 10),
        
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold, 
              ),
            ),
          ),
          const SizedBox(height: 5),
        
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio: \$$precio',
                  style: const TextStyle(
                    fontSize: 14, 
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Categoría: $categoria',
                  style: const TextStyle(
                    fontSize: 14, 
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ElevatedButton(// boton donde desplegaremos toda la info del producto y vendedor
              onPressed: () {
                
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ver más'),
            ),
          ),
          const SizedBox(height: 10), 
        ],
      ),
    );
  }
}
