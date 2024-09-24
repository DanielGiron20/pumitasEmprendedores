import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/db_helper.dart';
import 'package:pumitas_emprendedores/BaseDeDatos/usuario.dart';
import 'package:pumitas_emprendedores/mi_producto.dart';
import 'package:pumitas_emprendedores/wigets/background_painter.dart';
import 'package:pumitas_emprendedores/wigets/product_card.dart';

class MisProductos extends StatefulWidget {
  const MisProductos({super.key});

  @override
  _MisProductosState createState() => _MisProductosState();
}

class _MisProductosState extends State<MisProductos> {
  Usuario? _currentUser;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _allProducts = [];
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    List<Usuario> usuarios = await DBHelper.queryUsuarios();
    if (usuarios.isNotEmpty) {
      setState(() {
        _currentUser = usuarios.first;
      });
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection = firestore.collection('products');

    QuerySnapshot snapshot = await productsCollection
        .where('sellerId', isEqualTo: _currentUser!.id)
        .get();
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
        backgroundColor: const Color.fromARGB(255, 33, 46, 127),
        foregroundColor: const Color.fromARGB(255, 255, 211, 0),
        title: const Text('Mis Productos'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(),
            ),
          ),
          Column(
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
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_products.isEmpty) {
      return const Center(
        child: Text('No tienes productos disponibles.'),
      );
    }

    final size = MediaQuery.of(context).size;

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
        return FadeInUp(
            duration: Duration(milliseconds: 300 + index * 200),
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
                    builder: (context) => MiProductoPage(
                      name: product['name'],
                      description: product['description'],
                      image: product['image'],
                      price: product['price'],
                      category: product['category'],
                      sellerId: product['sellerId'],
                    ),
                  ),
                );
              },
            ));
      },
    );
  }
}
