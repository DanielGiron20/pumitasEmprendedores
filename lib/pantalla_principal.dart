import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/producto.dart';
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
  List<Map<String, dynamic>> _allProducts = [];
  final TextEditingController controller = TextEditingController();
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
          'sellerId': doc['sellerId'],
          'sellerName': doc['sellerName'],
        };
      }).toList();
      _allProducts = List.from(_products);
      _products.shuffle();
      _allProducts.shuffle();
    });
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _products = List.from(_allProducts);
      } else {
        final searchLower = query.toLowerCase();
        _products = _allProducts.where((product) {
          final nameLower = product['name'].toLowerCase();
          final categoryLower = product['category'].toLowerCase();
          final descriptionLower = product['description'].toLowerCase();

          return nameLower.contains(searchLower) ||
              categoryLower.contains(searchLower) ||
              descriptionLower.contains(searchLower);
        }).toList();
      }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                _searchProducts(value);
              },
            ),
          ),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Tamaño de la pantalla disponible
    final size = MediaQuery.of(context).size;

    // Calculamos el aspecto de las tarjetas
    final cardWidth =
        size.width / 2 - 16; // Ancho de la tarjeta (considerando margen)
    final cardHeight =
        cardWidth * 1.5; // Altura basada en la relación de aspecto

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        crossAxisSpacing: 8, // Espacio horizontal entre tarjetas
        mainAxisSpacing: 8, // Espacio vertical entre tarjetas
        childAspectRatio: cardWidth / cardHeight, // Relación de aspecto
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];

        // Añadimos un efecto de animación usando FadeIn o BounceIn
        return FadeInUp(
          // Puedes usar BounceIn, FadeIn, SlideIn, etc.
          duration: Duration(
              milliseconds:
                  250 + index * 200), // Retraso en la animación por tarjeta
          child: ProductCard(
            name: product['name'],
            description: product['description'],
            image: product['image'],
            price: product['price'],
            sellerId: product['sellerId'],
            sellerName: product['sellerName'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductoPage(
                    name: product['name'],
                    description: product['description'],
                    image: product['image'],
                    price: product['price'],
                    category: product['category'],
                    sellerName: product['sellerName'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
